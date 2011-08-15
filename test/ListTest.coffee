
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config
User = ron.create 'users'
User.identifier 'user_id'
User.unique 'username'
User.index 'email'
User.index 'name'

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
            { username: 'username_1', email: '1@email.com', password: 'my_password' }
            { username: 'username_2', email: '2@email.com', password: 'my_password' }
        ], (err, users) ->
            User.list { sort: 'username', direction: 'desc' }, (err, users) ->
                assert.ifError err
                assert.eql users.length, 2
                assert.eql users[0].username, 'username_2'
                assert.eql users[1].username, 'username_1'
                User.clear exit
    'Test list # where': (exit) ->
        User.create [
            { username: 'username_1', email: '1@email.com', password: 'my_password' }
            { username: 'username_2', email: '2@email.com', password: 'my_password' }
            { username: 'username_3', email: '1@email.com', password: 'my_password' }
        ], (err, users) ->
            User.list { email: '1@email.com', direction: 'desc' }, (err, users) ->
                assert.ifError err
                assert.eql users.length, 2
                assert.eql users[0].username, 'username_3'
                assert.eql users[1].username, 'username_1'
                User.clear exit
    'Test list # where union, same property': (exit) ->
        User.create [
            { username: 'username_1', email: '1@email.com', password: 'my_password' }
            { username: 'username_2', email: '2@email.com', password: 'my_password' }
            { username: 'username_3', email: '1@email.com', password: 'my_password' }
            { username: 'username_4', email: '4@email.com', password: 'my_password' }
        ], (err, users) ->
            User.list { email: ['1@email.com', '4@email.com'], operation: 'union', direction: 'desc' }, (err, users) ->
                assert.ifError err
                assert.eql users.length, 3
                assert.eql users[0].username, 'username_4'
                assert.eql users[1].username, 'username_3'
                assert.eql users[2].username, 'username_1'
                User.clear exit
    'Test list # where inter, same property': (exit) ->
        User.create [
            { username: 'username_1', email: '1@email.com', password: 'my_password', name: 'name_1' }
            { username: 'username_2', email: '2@email.com', password: 'my_password', name: 'name_2' }
            { username: 'username_3', email: '1@email.com', password: 'my_password', name: 'name_3' }
            { username: 'username_4', email: '4@email.com', password: 'my_password', name: 'name_4' }
        ], (err, users) ->
            User.list { email: '1@email.com', name: 'name_3', operation: 'inter', direction: 'desc' }, (err, users) ->
                assert.ifError err
                assert.eql users.length, 1
                assert.eql users[0].username, 'username_3'
                User.clear exit
    'destroy': (exit) ->
        ron.quit exit
