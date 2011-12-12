
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config
User = ron.define 'users'
User.identifier 'user_id'
User.unique 'username'
User.index 'email'
User.email 'email'

module.exports =
    'init': (exit) ->
        User.clear (err) ->
            assert.ifError err
            exit()
    'Test create validate # email with record': (exit) ->
        User.create
            username: 'my_username',
            email: 'invalid_email.com',
            password: 'my_password'
        , (err, user) ->
            assert.isNotNull err
            assert.eql err.message, 'Invalid email invalid_email.com'
            User.clear exit
    'destroy': (exit) ->
        ron.quit exit
