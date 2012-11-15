
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'create', ->

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
    # client.redis.flushdb next

  # afterEach (next) ->
  #   # Users.clear next
  #   client.redis.flushdb next
  
  after (next) ->
    client.quit next

  it 'Test create # one user', (next) ->
    Users.create
      username: 'my_username'
      email: 'my@email.com'
      password: 'my_password'
    , (err, user) ->
      should.not.exist err
      user.user_id.should.be.a 'number'
      user.email.should.eql 'my@email.com'
      # toto: Replace by User.remove
      Users.clear next

  it 'Test create # multiple users', (next) ->
    Users.create [
      username: 'my_username_1'
      email: 'my_first@email.com'
      password: 'my_password'
    ,
      username: 'my_username_2'
      email: 'my_second@email.com'
      password: 'my_password'
    ], (err, users) ->
      should.not.exist err
      users.length.should.eql 2
      users[0].password.should.eql 'my_password'
      # toto: Replace by Users.remove
      Users.clear next

  it 'Test create # existing id', (next) ->
    Users.create
      username: 'my_username'
      email: 'my@email.com'
      password: 'my_password'
    , (err, user) ->
      should.not.exist err
      Users.create {
        user_id: user.user_id,
        username: 'my_new_username',
        email: 'my_new@email.com',
        password: 'my_password'
      }, (err, user) ->
        err.message.should.eql 'Record 1 already exists'
        Users.clear next

  it 'Test create # unique exists', (next) ->
    Users.create
      username: 'my_username',
      email: 'my@email.com',
      password: 'my_password'
    , (err, user) ->
      should.not.exist err
      Users.create
        username: 'my_username'
        email: 'my@email.com'
        password: 'my_password'
      , (err, user) ->
        err.message.should.eql 'Record 1 already exists'
        Users.clear next

  it 'should only return the newly created identifiers', (next) ->
    Users.create [
      username: 'my_username_1'
      email: 'my_first@email.com'
      password: 'my_password'
    ,
      username: 'my_username_2'
      email: 'my_second@email.com'
      password: 'my_password'
    ], identifiers: true, (err, ids) ->
      should.not.exist err
      ids.length.should.equal 2
      for id in ids then id.should.be.a 'number'
      Users.clear next

  it 'should only return selected properties', (next) ->
    Users.create [
      username: 'my_username_1'
      email: 'my_first@email.com'
      password: 'my_password'
    ,
      username: 'my_username_2'
      email: 'my_second@email.com'
      password: 'my_password'
    ], properties: ['email'], (err, users) ->
      should.not.exist err
      users.length.should.equal 2
      for user in users then Object.keys(user).should.eql ['email']
      Users.clear next

  it 'should only insert defined properties', (next) ->
    Users.create
      username: 'my_username_1'
      email: 'my_first@email.com'
      zombie: 'e.t. maison'
    , (err, user) ->
      Users.get user.user_id, (err, user) ->
        should.not.exist user.zombie
        Users.clear next

  it 'should let you pass your own identifiers', (next) ->
    Users.create
      user_id: 1
      username: 'my_username_1'
    , (err, user) ->
      Users.get 1, (err, user) ->
        user.username.should.equal 'my_username_1'
        Users.clear next




