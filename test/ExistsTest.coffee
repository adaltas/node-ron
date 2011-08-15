
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config
User = ron.create 'users'
User.identifier 'user_id'
User.unique 'username'
User.index 'email'

create = (callback) ->
    User.create [
        username: 'my_username_1',
        email: 'my_1@email.com',
        password: 'my_password'
    ,
        username: 'my_username_2',
        email: 'my_2@email.com',
        password: 'my_password'
    ], (err, users) ->
        assert.ifError err
        callback(null, users)

module.exports =
    'init': (exit) ->
        User.clear (err) ->
            assert.ifError err
            exit()
    'Test exists # true # identifier': (exit) ->
        create (err, users) ->
            user = users[1]
            User.exists user.user_id, (err, userId) ->
                assert.ifError err
                assert.eql userId, user.user_id
                User.clear exit
    'Test exists # true # record with identifier': (exit) ->
        create (err, users) ->
            user = users[1]
            User.exists {user_id: user.user_id}, (err, userId) ->
                assert.ifError err
                assert.eql userId, user.user_id
                User.clear exit
    'Test exists # true # record with unique property stored in hash': (exit) ->
        create (err, users) ->
            user = users[1]
            User.exists {username: user.username}, (err, userId) ->
                assert.ifError err
                assert.eql userId, user.user_id
                User.clear exit
    'Test exists # false # indentifier': (exit) ->
        User.exists 'missing', (err, exists) ->
            assert.ok exists is null
            User.clear exit
    'Test exists # false # record with identifier': (exit) ->
        User.exists {user_id: 'missing'}, (err, exists) ->
            assert.ifError err
            assert.ok exists is null
            User.clear exit
    'Test exists # false # record with unique property stored in hash': (exit) ->
        User.exists {username: 'missing'}, (err, exists) ->
            assert.ifError err
            assert.ok exists is null
            User.clear exit
    'destroy': (exit) ->
        ron.quit exit
