
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config
User = ron.create 'users'
User.identifier 'id'

module.exports =
    'init': (exit) ->
        User.clear (err) ->
            assert.ifError err
            exit()
    'Test count': (exit) ->
        User.create [{
            username: '1my_username',
            email: '1my@email.com',
            password: 'my_password'
        },{
            username: '2my_username',
            email: '2my@email.com',
            password: 'my_password'
        }], (err, user) ->
            User.count (err, count) ->
                assert.ifError err
                assert.eql count, 2
                exit()
    'destroy': (exit) ->
        ron.quit exit
