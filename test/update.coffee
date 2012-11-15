
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

client = Users = null

before (next) ->
  client = ron config
  Users = client.get 'users'
  Users.identifier 'user_id'
  Users.unique 'username'
  Users.index 'email'
  next()

beforeEach (next) ->
  Users.clear next
  
afterEach (next) ->
  client.redis.keys '*', (err, keys) ->
    should.not.exists err
    keys.should.eql []
    next()

after (next) ->
  client.quit next

describe 'update', ->

  describe 'identifier', ->

    it 'missing id', (next) ->
      Users.update [{email: 'missing@email.com'}], (err, users) ->
        # Todo, could be "Record without identifier or unique properties
        err.message.should.eql 'Invalid record, got {"email":"missing@email.com"}' 
        Users.clear next

    it 'should use unique index and fail because the provided value is not indexed', (next) ->
      Users.update [{username: 'missing'}], (err, users) ->
        err.message.should.eql 'Unsaved record'
        Users.clear next

  describe 'unique', ->

    it 'should update a unique value', (next) ->
      Users.create 
        username: 'my_username'
        email: 'my@email.com'
        password: 'my_password'
      , (err, user) ->
        should.not.exist err
        user.username = 'new_username'
        Users.update user, (err, user) ->
          should.not.exist err
          user.username.should.eql 'new_username'
          Users.count (err, count) ->
            count.should.eql 1
            Users.get {username: 'my_username'}, (err, user) ->
              should.not.exist user
              Users.get {username: 'new_username'}, (err, user) ->
                user.username.should.eql 'new_username'
                Users.clear next

    it 'should fail to update a unique value that is already defined', (next) ->
      Users.create  [
        username: 'my_username_1'
        email: 'my@email.com'
        password: 'my_password'
      ,
        username: 'my_username_2'
        email: 'my@email.com'
        password: 'my_password'
      ], (err, users) ->
        should.not.exist err
        user = users[0]
        user.username = 'my_username_2'
        Users.update user, (err, user) ->
          err.message.should.eql 'Unique value already exists'
          Users.clear next

  describe 'index', ->

    it 'should update an indexed property', (next) ->
      Users.create  {
        username: 'my_username'
        email: 'my@email.com'
        password: 'my_password'
      }, (err, user) ->
        should.not.exist err
        user.email = 'new@email.com'
        Users.update user, (err, user) ->
          should.not.exist err
          user.email.should.eql 'new@email.com'
          Users.count (err, count) ->
            count.should.eql 1
            Users.list {email: 'my@email.com'}, (err, users) ->
              users.length.should.eql 0
              Users.list {email: 'new@email.com'}, (err, users) ->
                users.length.should.eql 1
                users[0].email.should.eql 'new@email.com'
                Users.clear next

    it 'should update an indexed property to null and be able to list the record', (next) ->
      Users.create  {
        username: 'my_username'
        email: 'my@email.com'
        password: 'my_password'
      }, (err, user) ->
        should.not.exist err
        user.email = null
        Users.update user, (err, user) ->
          should.not.exist err
          should.not.exist user.email
          Users.count (err, count) ->
            count.should.eql 1
            Users.list {email: 'my@email.com'}, (err, users) ->
              users.length.should.eql 0
              Users.list {email: null}, (err, users) ->
                users.length.should.eql 1
                should.not.exist users[0].email
                Users.clear next
