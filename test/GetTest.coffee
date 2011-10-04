
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
    'Test get # identifier': (exit) ->
        User.create
            username: 'my_username',
            email: 'my@email.com'
        , (err, user) ->
            userId = user.user_id
            # Test with a number
            User.get userId, (err, user) ->
                assert.ifError err
                assert.type user, 'object'
                assert.eql user.user_id, userId
                assert.eql user.username, 'my_username'
                assert.eql user.email, 'my@email.com'
                # Test with a string
                User.get '' + userId, (err, user) ->
                    assert.ifError err
                    assert.eql user.user_id, userId
                    User.clear exit
    'Test get # unique property': (exit) ->
        User.create
            username: 'my_username',
            email: 'my@email.com'
        , (err, user) ->
            userId = user.user_id
            User.get {username: 'my_username'}, (err, user) ->
                assert.ifError err
                assert.type user, 'object'
                assert.eql user.user_id, userId
                User.clear exit
    'Test get # unique property missing': (exit) ->
        User.get {username: 'my_missing_username'}, (err, user) ->
            assert.ifError err
            assert.isNull user
            User.clear exit
    'Test get # properties': (exit) ->
        User.create
            username: 'my_username',
            email: 'my@email.com',
        , (err, user) ->
            userId = user.user_id
            User.get userId, ['username'], (err, user) ->
                assert.ifError err
                assert.type user, 'object'
                assert.eql user.user_id, userId
                assert.eql user.username, 'my_username'
                assert.isUndefined user.email
                User.clear exit
    'destroy': (exit) ->
        ron.quit exit
