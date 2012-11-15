
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

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
  
afterEach (next) ->
  client.redis.keys '*', (err, keys) ->
    should.not.exists err
    keys.should.eql []
    next()

after (next) ->
  client.quit next

describe 'id', ->

  it "should take a number as the first argument", (next) ->
    Users.id 2, (err, users) ->
      users.length.should.eql 2
      ids = for user in users then user.user_id
      ids[0].should.eql ids[1] - 1
      Users.clear next

  it "should increment ids by default", (next) ->
    Users.id [{},{}], (err, users) ->
      users.length.should.eql 2
      ids = for user in users then user.user_id
      ids[0].should.eql ids[1] - 1
      Users.clear next