
should = require 'should'

try config = require '../conf/test' catch e
ron = require '../index'

describe 'count', ->

    client = Users = null
    
    before (next) ->
        client = ron config
        Users = client.get 'users'
        Users.identifier 'user_id'
        Users.unique 'username'
        Users.index 'email'
        next()

    beforeEach (next) ->
        Users.clear next
    
    after (next) ->
        client.quit next

    it 'should count the records', (next) ->
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