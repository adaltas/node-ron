
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config
User = ron.define 'users'
User.identifier 'user_id'
User.unique 'username'
User.index 'email'

module.exports =
    'init': (exit) ->
        User.clear (err) ->
            assert.ifError err
            exit()
    'Test update # missing id': (exit) ->
        User.update [{email: 'missing@email.com'}], (err, users) ->
            assert.isNotNull err
            assert.eql err.message, 'Invalid object, got {"email":"missing@email.com"}' # todo, could be "Record without identifier or unique properties
            User.clear exit
    'Test update # missing id with missing unique': (exit) ->
        User.update [{username: 'missing'}], (err, users) ->
            assert.isNotNull err
            assert.eql err.message, 'Unsaved record'
            User.clear exit
    'Test update # change unique': (exit) ->
        User.create  {
            username: 'my_username'
            email: 'my@email.com'
            password: 'my_password'
        }, (err, user) ->
            assert.ifError err
            user.username = 'new_username'
            User.update user, (err, user) ->
                assert.ifError err
                assert.eql user.username, 'new_username'
                User.count (err, count) ->
                    assert.eql count, 1
                    User.get {username: 'my_username'}, (err, user) ->
                        assert.isNull user
                        User.get {username: 'new_username'}, (err, user) ->
                            assert.isNotNull user
                            assert.eql user.username, 'new_username'
                            User.clear exit
    'Test update # change index': (exit) ->
        User.create  {
            username: 'my_username'
            email: 'my@email.com'
            password: 'my_password'
        }, (err, user) ->
            assert.ifError err
            user.email = 'new@email.com'
            User.update user, (err, user) ->
                assert.ifError err
                assert.eql user.email, 'new@email.com'
                User.count (err, count) ->
                    assert.eql count, 1
                    User.list {email: 'my@email.com'}, (err, users) ->
                        assert.eql users.length, 0
                        User.list {email: 'new@email.com'}, (err, users) ->
                            assert.isNotNull user
                            assert.eql users.length, 1
                            assert.eql users[0].email, 'new@email.com'
                            User.clear exit
    'Test update # change to null': (exit) ->
        User.create  {
            username: 'my_username'
            email: 'my@email.com'
            password: 'my_password'
        }, (err, user) ->
            assert.ifError err
            user.email = null
            User.update user, (err, user) ->
                assert.ifError err
                assert.eql user.email, null
                User.count (err, count) ->
                    assert.eql count, 1
                    #return User.clear exit
                    User.list {email: 'my@email.com'}, (err, users) ->
                        assert.eql users.length, 0
                        User.list {email: null}, (err, users) ->
                            assert.isNotNull user
                            assert.eql users.length, 1
                            assert.eql users[0].email, null
                            User.clear exit
    'destroy': (exit) ->
        ron.quit exit