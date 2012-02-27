
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'update', ->

    ron = User = null
    
    before (next) ->
        ron = Ron config
        User = ron.define 'users'
        User.identifier 'user_id'
        User.unique 'username'
        User.index 'email'
        next()

    beforeEach (next) ->
        User.clear next
    
    after (next) ->
        ron.quit next

    describe 'identifier', ->

        it 'missing id', (next) ->
            User.update [{email: 'missing@email.com'}], (err, users) ->
                # Todo, could be "Record without identifier or unique properties
                err.message.should.eql 'Invalid object, got {"email":"missing@email.com"}' 
                User.clear next

        it 'should use unique index and fail because the provided value is not indexed', (next) ->
            User.update [{username: 'missing'}], (err, users) ->
                err.message.should.eql 'Unsaved record'
                User.clear next

    describe 'unique', ->

        it 'should update a unique value', (next) ->
            User.create 
                username: 'my_username'
                email: 'my@email.com'
                password: 'my_password'
            , (err, user) ->
                should.not.exist err
                user.username = 'new_username'
                User.update user, (err, user) ->
                    should.not.exist err
                    user.username.should.eql 'new_username'
                    User.count (err, count) ->
                        count.should.eql 1
                        User.get {username: 'my_username'}, (err, user) ->
                            should.not.exist user
                            User.get {username: 'new_username'}, (err, user) ->
                                user.username.should.eql 'new_username'
                                User.clear next

        it 'should fail to update a unique value that is already defined', (next) ->
            User.create  [
                username: 'my_username_1'
                email: 'my@email.com'
                password: 'my_password'
            ,
                username: 'my_username_2'
                email: 'my@email.com'
                password: 'my_password'
            ], (err, users) ->
                should.not.exist err
                user = users[0]
                user.username = 'my_username_2'
                User.update user, (err, user) ->
                    err.message.should.eql 'Unique value already exists'
                    return User.clear next

    describe 'index', ->

        it 'should update an indexed property', (next) ->
            User.create  {
                username: 'my_username'
                email: 'my@email.com'
                password: 'my_password'
            }, (err, user) ->
                should.not.exist err
                user.email = 'new@email.com'
                User.update user, (err, user) ->
                    should.not.exist err
                    user.email.should.eql 'new@email.com'
                    User.count (err, count) ->
                        count.should.eql 1
                        User.list {email: 'my@email.com'}, (err, users) ->
                            users.length.should.eql 0
                            User.list {email: 'new@email.com'}, (err, users) ->
                                users.length.should.eql 1
                                users[0].email.should.eql 'new@email.com'
                                User.clear next

        it 'should update an indexed property to null and be able to list the record', (next) ->
            User.create  {
                username: 'my_username'
                email: 'my@email.com'
                password: 'my_password'
            }, (err, user) ->
                should.not.exist err
                user.email = null
                User.update user, (err, user) ->
                    should.not.exist err
                    should.not.exist user.email
                    User.count (err, count) ->
                        count.should.eql 1
                        User.list {email: 'my@email.com'}, (err, users) ->
                            users.length.should.eql 0
                            User.list {email: null}, (err, users) ->
                                users.length.should.eql 1
                                should.not.exist users[0].email
                                User.clear next
