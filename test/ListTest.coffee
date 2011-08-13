
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
    'Test list # sort': (exit) ->
        User.create [
            username: 'my_username_1',
            email: 'my_first@email.com',
            password: 'my_password'
        ,
            username: 'my_username_2',
            email: 'my_second@email.com',
            password: 'my_password'
        ], (err, users) ->
            User.list { sort: 'username', direction: 'desc' }, (err, users) ->
                assert.ifError err
                assert.eql users.length, 2
                assert.eql users[0].username, 'my_username_2'
                assert.eql users[1].username, 'my_username_1'
                User.clear exit
    'destroy': (exit) ->
        ron.quit exit
