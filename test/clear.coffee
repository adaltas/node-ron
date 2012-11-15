
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'all', ->

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

  it 'shall clear nothing if there are no record', (next) ->
    Users.all (err, users) ->
      users.length.should.equal 0
      Users.clear (err, count) ->
        should.not.exist err
        count.should.eql 0
        next()

  it 'shall clear simple records', (next) ->
    Records = client.get { name: 'records', properties: id_records: identifier: true }
    Records.all (err, users) ->
      users.length.should.equal 0
      Records.clear (err, count) ->
        should.not.exist err
        count.should.eql 0
        Records.create {}, (err, count) ->
          should.not.exist err
          Records.clear (err, count) ->
            should.not.exist err
            count.should.eql 1
            next()
    
