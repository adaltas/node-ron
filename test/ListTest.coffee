
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config
User = ron.create 'users'
User.identifier 'user_id'
User.unique 'username'
User.index 'email'

module.exports =
    'init': (exit) ->
        User.clear (err) ->
            assert.ifError err
            exit()
    'Test list # result empty': (exit) ->
        User.list { }, (err, users) ->
            assert.ifError err
            assert.eql users.length, 0
            exit()
    'Test list # sort': (exit) ->
        User.create [
            username: 'my_username_1'
            email: 'my_first@email.com'
            password: 'my_password'
        ,
            username: 'my_username_2'
            email: 'my_second@email.com'
            password: 'my_password'
        ], (err, users) ->
            User.list { sort: 'username', direction: 'desc' }, (err, users) ->
                assert.ifError err
                assert.eql users.length, 2
                assert.eql users[0].username, 'my_username_2'
                assert.eql users[1].username, 'my_username_1'
                User.clear exit
    'Test list # where': (exit) ->
        User.create [
            username: 'username_1'
            email: 'first@email.com'
            password: 'my_password'
        ,
            username: 'username_2'
            email: 'second@email.com'
            password: 'my_password'
        
        ,
            username: 'username_3'
            email: 'first@email.com'
            password: 'my_password'
        ], (err, users) ->
            User.list { email: 'first@email.com', direction: 'desc' }, (err, users) ->
                assert.ifError err
                assert.eql users.length, 2
                assert.eql users[0].username, 'username_3'
                assert.eql users[1].username, 'username_1'
                User.clear exit
    'destroy': (exit) ->
        ron.quit exit
