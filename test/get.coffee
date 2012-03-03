
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'get', ->

    ron = Users = null
    
    before (next) ->
        ron = Ron config
        ron.schema
            name: 'users'
            properties: 
                user_id: identifier: true
                username: unique: true
                email: index: true
        Users = ron.get 'users'
        next()

    beforeEach (next) ->
        Users.clear next
    
    after (next) ->
        ron.quit next

    it 'Test get # identifier', (next) ->
        Users.create
            username: 'my_username',
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

    it 'Test get # unique property', (next) ->
        Users.create
            username: 'my_username',
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

    it 'Test get # properties', (next) ->
        Users.create
            username: 'my_username',
            email: 'my@email.com',
        , (err, user) ->
            userId = user.user_id
            Users.get userId, ['username'], (err, user) ->
                should.not.exist err
                user.user_id.should.eql userId
                user.username.should.eql 'my_username'
                should.not.exist user.email
                Users.clear next
