
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'get', ->

    ron = User = null
    
    before (next) ->
        ron = Ron config
        User = ron.define 'users'
        User.identifier 'user_id'
        User.unique 'username'
        User.index 'email'
        next()

    beforeEach (next) ->
        User.clear next
    
    after (next) ->
        ron.quit next

    it 'Test get # identifier', (next) ->
        User.create
            username: 'my_username',
            email: 'my@email.com'
        , (err, user) ->
            userId = user.user_id
            # Test with a number
            User.get userId, (err, user) ->
                should.not.exist err
                user.user_id.should.eql userId
                user.username.should.eql 'my_username'
                user.email.should.eql 'my@email.com'
                # Test with a string
                User.get '' + userId, (err, user) ->
                    should.not.exist err
                    user.user_id.should.eql userId
                    User.clear next

    it 'Test get # unique property', (next) ->
        User.create
            username: 'my_username',
            email: 'my@email.com'
        , (err, user) ->
            userId = user.user_id
            User.get {username: 'my_username'}, (err, user) ->
                should.not.exist err
                user.user_id.should.eql userId
                User.clear next

    it 'Test get # unique property missing', (next) ->
        User.get {username: 'my_missing_username'}, (err, user) ->
            should.not.exist err
            should.not.exist user
            User.clear next

    it 'Test get # properties', (next) ->
        User.create
            username: 'my_username',
            email: 'my@email.com',
        , (err, user) ->
            userId = user.user_id
            User.get userId, ['username'], (err, user) ->
                should.not.exist err
                user.user_id.should.eql userId
                user.username.should.eql 'my_username'
                should.not.exist user.email
                User.clear next
