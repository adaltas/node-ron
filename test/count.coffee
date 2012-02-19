
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'count', ->

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

    it 'Test count', (next) ->
        User.create [
            username: '1my_username',
            email: '1my@email.com',
            password: 'my_password'
        ,
            username: '2my_username',
            email: '2my@email.com',
            password: 'my_password'
        ], (err, user) ->
            User.count (err, count) ->
                should.not.exist err
                count.should.eql 2
                next()