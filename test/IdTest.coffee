
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config
User = ron.create 'users'
User.identifier 'user_id'
User.unique 'username'
User.index 'email'
User.unique 'email'

module.exports =
    'init': (exit) ->
        User.clear (err) ->
            assert.ifError err
            exit()
    'Test id # number': (exit) ->
        User.id 3, (err, userId) ->
            assert.ifError(err)
            assert.eql userId, 3
            User.id [3], (err, userId) ->
                assert.ifError(err)
                assert.eql userId, [3]
                exit()
    'Test id # user.user_id': (exit) ->
        User.id {user_id: 3}, (err, userId) ->
            assert.ifError(err)
            assert.eql userId, 3
            User.id [{user_id: 3, username: 'my_username'}], (err, userId) ->
                assert.ifError(err)
                assert.eql userId, [3]
                exit()
    'Test id # user.username': (exit) ->
        User.create {
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        }, (err, user) ->
            # Pass an object
            User.id {username: 'my_username'}, (err, userId) ->
                assert.ifError(err)
                assert.eql userId, user.user_id
                # Pass an array of ids and objects
                User.id [1, {username: 'my_username'}, 2], (err, userId) ->
                    assert.ifError(err)
                    assert.eql userId, [1, user.user_id, 2]
                    User.clear exit
    'Test id # invalid object empty': (exit) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's an empty object
        User.id [1, {}, {user_id: 2}], (err, user) ->
            assert.type err, 'object'
            assert.isNotNull err
            assert.eql err.message, 'Invalid object, got {}'
            User.id {}, (err, user) ->
                assert.type err, 'object'
                assert.isNotNull err
                assert.eql err.message, 'Invalid object, got {}'
                User.clear exit
    'Test id # missing unique': (exit) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's an empty object
        User.create [
            { username: 'my_username_1', email: 'my1@mail.com' },
            { username: 'my_username_2', email: 'my2@mail.com' }
        ], (err, users) ->
            # Test return id
            User.id [
                { username: users[1].username }     # By unique
                { user_id: users[0].user_id }       # By identifier
                { username: 'who are you' }         # Alien
            ], (err, result) ->
                assert.eql users[0].user_id, result[1]
                assert.eql users[1].user_id, result[0]
                assert.isNull result[2]
                User.clear exit
    'Test id # missing unique + option object': (exit) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's an empty object
        User.create [
            { username: 'my_username_1', email: 'my1@mail.com' },
            { username: 'my_username_2', email: 'my2@mail.com' }
        ], (err, users) ->
            User.id [
                { username: users[1].username }     # By unique
                { user_id: users[0].user_id }       # By identifier
                { username: 'who are you' }         # Alien
            ], {object: true}, (err, result) ->
                # Test return object
                assert.eql users[0].user_id, result[1].user_id
                assert.eql users[1].user_id, result[0].user_id
                assert.eql result[2].user_id, null
                User.clear exit
    'Test id # invalid type id': (exit) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's a boolean
        User.id [1, true, {user_id: 2}], (err, user) ->
            assert.type err, 'object'
            assert.isNotNull err
            assert.eql err.message, 'Invalid id, got true'
            User.id false, (err, user) ->
                assert.type err, 'object'
                assert.isNotNull err
                assert.eql err.message, 'Invalid id, got false'
                User.clear exit
    'Test id # invalid type null': (exit) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's a boolean
        User.id [1, null, {user_id: 2}], (err, users) ->
            assert.type err, 'object'
            assert.isNotNull err
            assert.eql err.message, 'Invalid object, got null'
            User.id null, (err, user) ->
                assert.type err, 'object'
                assert.isNotNull err
                assert.eql err.message, 'Invalid object, got null'
                User.clear exit
    'Test id # accept null': (exit) ->
        # Test an array of 3 arguments, 
        # but the second is invalid since it's a boolean
        User.id [1, null, {user_id: 2}], {accept_null: true}, (err, users) ->
            assert.ifError err
            assert.ok Array.isArray users
            assert.eql users.length, 3
            assert.isNotNull users[0]
            assert.isNull users[1]
            assert.isNotNull users[2]
            # Test null
            User.id null, {accept_null: true}, (err, user) ->
                assert.ifError err
                assert.isNull user
                User.clear exit
    'Test id # accept null return object': (exit) ->
        # Same test than 'Test id # accept null' with the 'object' option
        User.id [1, null, {user_id: 2}], {accept_null: true, object: true}, (err, users) ->
            assert.ifError err
            assert.ok Array.isArray users
            assert.eql users.length, 3
            assert.eql users[0].user_id, 1
            assert.isNull users[1]
            assert.eql users[2].user_id, 2
            # Test null
            User.id null, {accept_null: true, object: true}, (err, user) ->
                assert.ifError err
                assert.isNull user
                User.clear exit
    'Test id # id return object': (exit) ->
        User.create {
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        }, (err, orgUser) ->
            # Pass an id
            User.id orgUser.user_id, {object: true}, (err, user) ->
                assert.ifError err
                assert.type user, 'object'
                assert.eql user, {user_id: orgUser.user_id}
                # Pass an array of ids
                User.id [orgUser.user_id, orgUser.user_id], {object: true}, (err, user) ->
                    assert.ifError(err)
                    assert.eql user, [{user_id: orgUser.user_id}, {user_id: orgUser.user_id}]
                    User.clear exit
    'Test id # unique + option object': (exit) ->
        User.create {
            username: 'my_username',
            email: 'my@email.com',
            password: 'my_password'
        }, (err, orgUser) ->
            # Pass an object
            User.id {username: 'my_username'}, {object: true}, (err, user) ->
                assert.ifError(err)
                assert.type user, 'object'
                assert.eql user, {username: 'my_username', user_id: orgUser.user_id}
                # Pass an array of ids and objects
                User.id [1, {username: 'my_username'}, 2], {object: true}, (err, user) ->
                    assert.ifError(err)
                    assert.eql user, [{user_id: 1}, {username: 'my_username', user_id: orgUser.user_id}, {user_id: 2}]
                    User.clear exit
    'destroy': (exit) ->
        ron.quit exit
