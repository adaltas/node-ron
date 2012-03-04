
should = require 'should'

try config = require '../conf/test' catch e
ron = require '../index'

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

    it 'shall create 2 users and list them', (next) ->
        Users.create [
            username: 'my_username_1',
            email: 'my_first@email.com',
            password: 'my_password'
        ,
            username: 'my_username_2',
            email: 'my_second@email.com',
            password: 'my_password'
        ], (err, users) ->
            Users.all (err, users) ->
                should.not.exist err
                users.length.should.eql 2
                users[0].password.should.eql 'my_password'
                next()
        
