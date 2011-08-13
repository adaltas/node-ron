
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
    'Test remove': (exit) ->
        User.create {
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        }, (err, user) ->
            User.remove user.user_id, (err, count) ->
                assert.ifError err
                assert.eql count, 1
                User.exists user.user_id, (err, exists) ->
                    assert.eql exists, false
                    exit()
    'destroy': (exit) ->
        ron.quit exit
