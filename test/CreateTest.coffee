
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config
User = ron.create 'users'
User.identifier 'user_id'

module.exports =
    'init': (exit) ->
        User.clear (err) ->
            assert.ifError err
            exit()
    'Test create # one user': (exit) ->
        User.create {
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        }, (err, user) ->
            assert.ifError err
            assert.type user, 'object'
            assert.type user.user_id, 'number'
            assert.eql user.email, 'my@email.com'
            # toto: Replace by User.remove
            User.clear exit
    'Test create # multiple users': (exit) ->
        User.create [
            username: 'my_username_1',
            email: 'my_first@email.com',
            password: 'my_password'
        ,
            username: 'my_username_2',
            email: 'my_second@email.com',
            password: 'my_password'
        ], (err, users) ->
            assert.ifError err
            assert.ok Array.isArray(users)
            assert.eql users.length, 2
            assert.eql users[0].password, 'my_password'
            # toto: Replace by User.remove
            User.clear exit
    'Test create # existing id': (exit) ->
        User.create {
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        }, (err, user) ->
            assert.ifError err
            User.create {
                user_id: user.user_id,
                username: 'my_new_username',
                email: 'my_new@email.com',
                password: 'my_password'
            }, (err, user) ->
                assert.isNotNull err
                assert.eql err.message, 'User 1 already exists'
                User.clear exit
    'Test create # unique exists': (exit) ->
        User.create {
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        }, (err, user) ->
            assert.ifError err
            User.create {
                username: 'my_username',
                email: 'my@email.com',
                password: 'my_password'
            }, (err, user) ->
                assert.isNotNull err
                assert.eql err.message, 'User 1 already exists'
                User.clear exit
    'destroy': (exit) ->
        ron.quit exit
