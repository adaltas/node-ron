
should = require 'should'

config = require '../conf/test'
Ron = require '../index'

describe 'remove', ->

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

    it 'Test remove # from identifier', (next) ->
        User.create {
            username: 'my_username'
            email: 'my@email.com'
            password: 'my_password'
        }, (err, user) ->
            # Delete record bsed on identifier
            User.remove user.user_id, (err, count) ->
                should.not.exist err
                count.should.eql 1
                # Check record doesn't exist
                User.exists user.user_id, (err, exists) ->
                    should.not.exist exists
                    next()
