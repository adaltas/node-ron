
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'create_validation', ->

  client = Users = null
  
  before (next) ->
    client = ron config
    Users = client.get
      name: 'users'
      properties: 
        user_id: identifier: true
        email: {type: 'email', index: true}
    next()

  beforeEach (next) ->
    Users.clear next
  
  after (next) ->
    client.quit next

  it 'should validate email on creation', (next) ->
    Users.create
      email: 'invalid_email.com'
    , validate: true, (err, user) ->
      err.message.should.eql 'Invalid email invalid_email.com'
      user.email.should.eql 'invalid_email.com'
      Users.create
        email: 'valid@email.com'
      , validate: true, (err, user) ->
        should.not.exist err
        Users.clear next

  it 'should validate email on update', (next) ->
    Users.create
      email: 'valid@email.com'
    , (err, user) ->
      Users.update
        user_id: user.user_id
        email: 'invalid_email.com'
      , validate: true, (err, user) ->
        err.message.should.eql 'Invalid email invalid_email.com'
        Users.update
          user_id: user.user_id
          email: 'valid@email.com'
        , validate: true, (err, user) ->
          should.not.exist err
          Users.clear next




