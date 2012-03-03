
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'remove', ->

    ron = Users = null
    
    before (next) ->
        ron = Ron config
        schema = ron.schema 'users'
        schema.identifier 'user_id'
        schema.unique 'username'
        schema.index 'email'
        Users = ron.get 'users'
        next()

    beforeEach (next) ->
        Users.clear next
    
    after (next) ->
        ron.quit next

    it 'Test remove # from identifier', (next) ->
        Users.create {
            username: 'my_username'
            email: 'my@email.com'
            password: 'my_password'
        }, (err, user) ->
            # Delete record bsed on identifier
            Users.remove user.user_id, (err, count) ->
                should.not.exist err
                count.should.eql 1
                # Check record doesn't exist
                Users.exists user.user_id, (err, exists) ->
                    should.not.exist exists
                    next()
