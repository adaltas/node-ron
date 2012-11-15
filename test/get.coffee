
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'get', ->

  client = Users = null
  
  before (next) ->
    client = ron config
    Users = client.get
      name: 'users'
      properties: 
        user_id: identifier: true
        username: unique: true
        email: index: true
    next()

  beforeEach (next) ->
    Users.clear next
  
  after (next) ->
    client.quit next

  it 'should use a provided identifier', (next) ->
    Users.create
      username: 'my_username'
      email: 'my@email.com'
    , (err, user) ->
      userId = user.user_id
      # Test with a number
      Users.get userId, (err, user) ->
        should.not.exist err
        user.user_id.should.eql userId
        user.username.should.eql 'my_username'
        user.email.should.eql 'my@email.com'
        # Test with a string
        Users.get '' + userId, (err, user) ->
          should.not.exist err
          user.user_id.should.eql userId
          Users.clear next

  it 'should faild with a missing identifier', (next) ->
    Users.get -1, (err, user) ->
      should.not.exist err
      should.not.exist user
      Users.clear next

  it 'Test get # unique property', (next) ->
    Users.create
      username: 'my_username'
      email: 'my@email.com'
    , (err, user) ->
      userId = user.user_id
      Users.get {username: 'my_username'}, (err, user) ->
        should.not.exist err
        user.user_id.should.eql userId
        Users.clear next

  it 'Test get # unique property missing', (next) ->
    Users.get {username: 'my_missing_username'}, (err, user) ->
      should.not.exist err
      should.not.exist user
      Users.clear next

  it 'should only return the provided properties', (next) ->
    Users.create
      username: 'my_username'
      email: 'my@email.com'
    , (err, user) ->
      userId = user.user_id
      Users.get userId, ['username'], (err, user) ->
        should.not.exist err
        user.user_id.should.eql userId
        user.username.should.eql 'my_username'
        should.not.exist user.email
        Users.clear next

  it 'should be able to get null records with option accept_null', (next) ->
    Users.create
      username: 'my_username',
      email: 'my@email.com',
    , (err, user) ->
      userId = user.user_id
      # A single null record
      Users.get null, accept_null: true, (err, user) ->
        should.not.exist err
        should.not.exist user
        # Multiple all null records
        Users.get [null, null], accept_null: true, (err, users) ->
          should.not.exist err
          users.length.should.eql 2
          for user in users then should.not.exist user
          # Multiple with null records
          Users.get [null, userId, null], accept_null: true, (err, users) ->
            should.not.exist err
            users.length.should.eql 3
            should.not.exist users[0]
            users[1].username.should.eql 'my_username'
            should.not.exist users[2]
            Users.clear next

  it 'should return an object where keys are the identifiers with option `object`', (next) ->
    Users.create [
      username: 'username_1'
    ,
      username: 'username_2'
    ,
      username: 'username_3'
    ], identifiers: true, (err, ids) ->
      Users.get ids, object: true, (err, users) ->
        Object.keys(users).length.should.eql 3
        for id, user of users then id.should.eql "#{user.user_id}"
        Users.clear next











