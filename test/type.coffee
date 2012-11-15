
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'type', ->

  client = Users = null
  
  before (next) ->
    client = ron config
    next()
  
  after (next) ->
    client.quit next

  it 'should filter properties', (next) ->
    Users = client.get 'users', temporal: true, properties: 
      user_id: identifier: true
      username: unique: true
      email: index: true
    Users.create 
      username: 'my_username',
      email: 'my@email.com',
      password: 'my_password'
    , (err, user) ->
      properties = ['email', 'user_id']
      Users.unserialize user, properties: properties
      Object.keys(user).should.eql properties
      Users.clear next