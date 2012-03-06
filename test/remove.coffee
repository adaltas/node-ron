
should = require 'should'

try config = require '../conf/test' catch e
ron = require '../index'

describe 'remove', ->

    client = Users = null
    
    before (next) ->
        client = ron config
        Users = client.get 'users'
        Users.identifier 'user_id'
        Users.unique 'username'
        Users.index 'email'
        Users = client.get 'users'
        next()

    beforeEach (next) ->
        Users.clear next
    
    after (next) ->
        client.quit next

    it 'should remove a record if providing an identifier', (next) ->
        Users.create {
            username: 'my_username'
            email: 'my@email.com'
            password: 'my_password'
        }, (err, user) ->
            # Delete record based on identifier
            Users.remove user.user_id, (err, count) ->
                should.not.exist err
                count.should.eql 1
                # Check record doesn't exist
                Users.exists user.user_id, (err, exists) ->
                    should.not.exist exists
                    next()
