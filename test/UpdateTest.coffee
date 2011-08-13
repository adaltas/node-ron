
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
    'Test update # missing id': (exit) ->
        User.update [{email: 'my_invalid@email.com'}], (err, users) ->
            assert.isNotNull err
            assert.eql err.message, 'Unsaved record'
            User.clear exit
    'Test update # change email': (exit) ->
        User.create  {
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        }, (err, user) ->
            assert.ifError err
            user.email = 'my_new@email.com'
            User.update user, (err, user) ->
                assert.ifError err
                assert.eql user.email, 'my_new@email.com'
                User.count (err, count) ->
                    assert.eql count, 1
                    User.get {email: 'my_new@email.com'}, (err, user) ->
                        assert.isNotNull user
                        assert.eql user.email, 'my_new@email.com'
                        User.get {email: 'my@email.com'}, (err, user) ->
                            assert.isNull user
                            User.clear exit
    'destroy': (exit) ->
        ron.quit exit