
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'id', ->

  client = Users = null
  
  before (next) ->
    client = ron config
    Users = client.get 
      name: 'users'
      properties: 
        user_id: identifier: true
    next()

  beforeEach (next) ->
    Users.clear next
  
  after (next) ->
    client.quit next

  it "should take a number as the first argument", (next) ->
    Users.id 2, (err, users) ->
      users.length.should.eql 2
      ids = for user in users then user.user_id
      ids[0].should.eql ids[1] - 1
      next()

  it "should increment ids by default", (next) ->
    Users.id [{},{}], (err, users) ->
      users.length.should.eql 2
      ids = for user in users then user.user_id
      ids[0].should.eql ids[1] - 1
      next()