
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'list', ->

  client = Users = null
  
  before (next) ->
    client = ron config
    Users = client.get
      name: 'users'
      properties: 
        user_id: identifier: true
        username: unique: true
        email: index: true
        name: index: true
    next()

  beforeEach (next) ->
    Users.clear next
  
  after (next) ->
    client.quit next

  it 'should be empty if there are no record', (next) ->
    Users.list { }, (err, users) ->
      should.not.exist err
      users.length.should.eql 0
      next()

  it 'should sort record according to one property', (next) ->
    Users.create [
      { username: 'username_1', email: '1@email.com', password: 'my_password' }
      { username: 'username_2', email: '2@email.com', password: 'my_password' }
    ], (err, users) ->
      Users.list { sort: 'username', direction: 'desc' }, (err, users) ->
        should.not.exist err
        users.length.should.eql 2
        users[0].username.should.eql 'username_2'
        users[1].username.should.eql 'username_1'
        Users.clear next

  it 'Test list # where', (next) ->
    Users.create [
      { username: 'username_1', email: '1@email.com', password: 'my_password' }
      { username: 'username_2', email: '2@email.com', password: 'my_password' }
      { username: 'username_3', email: '1@email.com', password: 'my_password' }
    ], (err, users) ->
      Users.list { email: '1@email.com', direction: 'desc' }, (err, users) ->
        should.not.exist err
        users.length.should.eql 2
        users[0].username.should.eql 'username_3'
        users[1].username.should.eql 'username_1'
        Users.clear next

  it 'Test list # where union, same property', (next) ->
    Users.create [
      { username: 'username_1', email: '1@email.com', password: 'my_password' }
      { username: 'username_2', email: '2@email.com', password: 'my_password' }
      { username: 'username_3', email: '1@email.com', password: 'my_password' }
      { username: 'username_4', email: '4@email.com', password: 'my_password' }
    ], (err, users) ->
      Users.list { email: ['1@email.com', '4@email.com'], operation: 'union', direction: 'desc' }, (err, users) ->
        should.not.exist err
        users.length.should.eql 3
        users[0].username.should.eql 'username_4'
        users[1].username.should.eql 'username_3'
        users[2].username.should.eql 'username_1'
        Users.clear next

  it 'should honor inter operation with a property having the same values', (next) ->
    Users.create [
      { username: 'username_1', email: '1@email.com', password: 'my_password', name: 'name_1' }
      { username: 'username_2', email: '2@email.com', password: 'my_password', name: 'name_2' }
      { username: 'username_3', email: '1@email.com', password: 'my_password', name: 'name_3' }
      { username: 'username_4', email: '4@email.com', password: 'my_password', name: 'name_4' }
    ], (err, users) ->
      Users.list { email: '1@email.com', name: 'name_3', operation: 'inter', direction: 'desc' }, (err, users) ->
        should.not.exist err
        users.length.should.eql 1
        users[0].username.should.eql 'username_3'
        Users.clear next

  it 'should return only selected properties', (next) ->
    Users.create [
      { username: 'username_1', email: '1@email.com', password: 'my_password', name: 'name_1' }
      { username: 'username_2', email: '2@email.com', password: 'my_password', name: 'name_2' }
    ], (err, users) ->
      Users.list { properties: ['username'], sort: 'username', direction: 'desc' }, (err, users) ->
        should.not.exist err
        users.length.should.eql 2
        for user in users then Object.keys(user).should.eql ['username']
        users[0].username.should.eql 'username_2'
        users[1].username.should.eql 'username_1'
        Users.clear next

  it 'should return an array of identifiers', (next) ->
    Users.create [
      { username: 'username_1', email: '1@email.com', password: 'my_password' }
      { username: 'username_2', email: '2@email.com', password: 'my_password' }
    ], (err, users) ->
      Users.list { identifiers: true }, (err, ids) ->
        should.not.exist err
        ids.length.should.eql 2
        for id in ids then id.should.be.a 'number'
        Users.clear next
