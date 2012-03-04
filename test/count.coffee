
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'count', ->

    ron = Users = null
    
    before (next) ->
        ron = Ron config
        Users = ron.get 'users'
        Users.identifier 'user_id'
        Users.unique 'username'
        Users.index 'email'
        next()

    beforeEach (next) ->
        Users.clear next
    
    after (next) ->
        ron.quit next

    it 'Test count', (next) ->
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