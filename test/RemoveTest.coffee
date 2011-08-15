
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
            # Delete record bsed on identifier
            User.remove user.user_id, (err, count) ->
                assert.ifError err
                assert.eql count, 1
                # Check record doesn't exist
                User.exists user.user_id, (err, exists) ->
                    assert.eql exists, null
                    exit()
    'destroy': (exit) ->
        ron.quit exit
