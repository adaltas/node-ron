
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'exists', ->

  create = (callback) ->
    Users.create [
      username: 'my_username_1',
      email: 'my_1@email.com',
      password: 'my_password'
    ,
      username: 'my_username_2',
      email: 'my_2@email.com',
      password: 'my_password'
    ], (err, users) ->
      should.ifError err
      callback(null, users)

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

  it 'Test exists # true # identifier', (next) ->
    create (err, users) ->
      user = users[1]
      Users.exists user.user_id, (err, userId) ->
        should.not.exist err
        userId.should.eql user.user_id
        Users.clear next

  it 'Test exists # true # record with identifier', (next) ->
    create (err, users) ->
      user = users[1]
      Users.exists {user_id: user.user_id}, (err, userId) ->
        should.not.exist err
        userId.should.eql user.user_id
        Users.clear next

  it 'Test exists # true # record with unique property stored in hash', (next) ->
    create (err, users) ->
      user = users[1]
      Users.exists {username: user.username}, (err, userId) ->
        should.not.exist err
        userId.should.eql user.user_id
        Users.clear next

  it 'Test exists # false # indentifier', (next) ->
    Users.exists 'missing', (err, exists) ->
      should.not.exist err
      should.not.exist exists
      Users.clear next

  it 'Test exists # false # record with identifier', (next) ->
    Users.exists {user_id: 'missing'}, (err, exists) ->
      should.not.exist err
      should.not.exist exists
      Users.clear next

  it 'Test exists # false # record with unique property stored in hash', (next) ->
    Users.exists {username: 'missing'}, (err, exists) ->
      should.not.exist err
      should.not.exist exists
      Users.clear next


