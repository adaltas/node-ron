
should = require 'should'

config = require '../conf/test'
Ron = require '../index'

describe 'create_validation', ->

    ron = User = null
    
    before (next) ->
        ron = Ron config
        User = ron.define 'users'
        User.identifier 'user_id'
        User.unique 'username'
        User.index 'email'
        User.email 'email'
        next()

    beforeEach (next) ->
        User.clear next
    
    after (next) ->
        ron.quit next

    it 'Test create validate # email with record', (next) ->
        User.create
            username: 'my_username',
            email: 'invalid_email.com',
            password: 'my_password'
        , (err, user) ->
            err.message.should.eql 'Invalid email invalid_email.com'
            User.clear next
