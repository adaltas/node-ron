
should = require 'should'

config = require '../conf/test'
Ron = require '../index'

describe 'create', ->

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

    it 'Test create # one user', (next) ->
        User.create
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        , (err, user) ->
            should.not.exist err
            user.user_id.should.be.a 'number'
            user.email.should.eql 'my@email.com'
            # toto: Replace by User.remove
            User.clear next

    it 'Test create # multiple users', (next) ->
        User.create [
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
            # toto: Replace by User.remove
            User.clear next

    it 'Test create # existing id', (next) ->
        User.create
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        , (err, user) ->
            should.not.exist err
            User.create {
                user_id: user.user_id,
                username: 'my_new_username',
                email: 'my_new@email.com',
                password: 'my_password'
            }, (err, user) ->
                err.message.should.eql 'Record 1 already exists'
                User.clear next

    it 'Test create # unique exists', (next) ->
        User.create
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        , (err, user) ->
            should.not.exist err
            User.create
                username: 'my_username',
                email: 'my@email.com',
                password: 'my_password'
            , (err, user) ->
                err.message.should.eql 'Record 1 already exists'
                User.clear next



