
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'count', ->

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
  
  after (next) ->
    client.quit next

  it 'should count the records', (next) ->
    Users.create [
      username: '1my_username',
      email: '1my@email.com',
      password: 'my_password'
    ,
      username: '2my_username',
      email: '2my@email.com',
      password: 'my_password'
    ], (err, user) ->
      Users.count (err, count) ->
        should.not.exist err
        count.should.eql 2
        next()

  it 'should count the index elements of a property', (next) ->
    Users.create [
      username: 'username_1',
      email: 'my@email.com',
      password: 'my_password'
    ,
      username: 'username_2',
      email: 'my_2@email.com',
      password: 'my_password'
    ,
      username: 'username_3',
      email: 'my@email.com',
      password: 'my_password'
    ], (err, user) ->
      # Count one value
      Users.count 'email', 'my@email.com', (err, count) ->
        should.not.exist err
        count.should.eql 2
        # Count multiple values
        Users.count 'email', ['my@email.com', 'my_2@email.com'], (err, counts) ->
          should.not.exist err
          counts[0].should.eql 2
          counts[1].should.eql 1
          next()

