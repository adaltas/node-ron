
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'all', ->

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

    it 'shall create 2 users and list them', (next) ->
        User.create [
            username: 'my_username_1',
            email: 'my_first@email.com',
            password: 'my_password'
        ,
            username: 'my_username_2',
            email: 'my_second@email.com',
            password: 'my_password'
        ], (err, users) ->
            User.all (err, users) ->
                should.not.exist err
                users.length.should.eql 2
                users[0].password.should.eql 'my_password'
                next()
        
