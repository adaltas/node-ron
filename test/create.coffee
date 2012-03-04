
should = require 'should'

try config = require '../conf/test' catch e
ron = require '../index'

describe 'create', ->

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

    it 'Test create # one user', (next) ->
        Users.create
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        , (err, user) ->
            should.not.exist err
            user.user_id.should.be.a 'number'
            user.email.should.eql 'my@email.com'
            # toto: Replace by User.remove
            Users.clear next

    it 'Test create # multiple users', (next) ->
        Users.create [
            username: 'my_username_1',
            email: 'my_first@email.com',
            password: 'my_password'
        ,
            username: 'my_username_2',
            email: 'my_second@email.com',
            password: 'my_password'
        ], (err, users) ->
            should.not.exist err
            users.length.should.eql 2
            users[0].password.should.eql 'my_password'
            # toto: Replace by Users.remove
            Users.clear next

    it 'Test create # existing id', (next) ->
        Users.create
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        , (err, user) ->
            should.not.exist err
            Users.create {
                user_id: user.user_id,
                username: 'my_new_username',
                email: 'my_new@email.com',
                password: 'my_password'
            }, (err, user) ->
                err.message.should.eql 'Record 1 already exists'
                Users.clear next

    it 'Test create # unique exists', (next) ->
        Users.create
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        , (err, user) ->
            should.not.exist err
            Users.create
                username: 'my_username',
                email: 'my@email.com',
                password: 'my_password'
            , (err, user) ->
                err.message.should.eql 'Record 1 already exists'
                Users.clear next



