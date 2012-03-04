
should = require 'should'

try config = require '../conf/test' catch e
ron = require '../index'

describe 'create_validation', ->

    client = Users = null
    
    before (next) ->
        client = ron config
        Users = client.get
            name: 'users'
            properties: 
                user_id: identifier: true
                username: unique: true
                email: {index: true, email: true}
        next()

    beforeEach (next) ->
        Users.clear next
    
    after (next) ->
        client.quit next

    it 'Test create validate # email with record', (next) ->
        Users.create
            username: 'my_username',
            email: 'invalid_email.com',
            password: 'my_password'
        , (err, user) ->
            err.message.should.eql 'Invalid email invalid_email.com'
            Users.clear next
