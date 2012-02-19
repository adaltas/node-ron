
should = require 'should'

config = require '../conf/test'
Ron = require '../index'

describe 'list', ->

    ron = User = null
    
    before (next) ->
        ron = Ron config
        User = ron.define 'users'
        User.identifier 'user_id'
        User.unique 'username'
        User.index 'email'
        User.index 'name'
        next()

    beforeEach (next) ->
        User.clear next
    
    after (next) ->
        ron.quit next

    ron = Ron config
    User = ron.define 'users'
    User.identifier 'user_id'
    User.unique 'username'
    User.index 'email'
    User.index 'name'

    it 'Test list # result empty', (next) ->
        User.list { }, (err, users) ->
            should.not.exist err
            users.length.should.eql 0
            next()

    it 'Test list # sort', (next) ->
        User.create [
            { username: 'username_1', email: '1@email.com', password: 'my_password' }
            { username: 'username_2', email: '2@email.com', password: 'my_password' }
        ], (err, users) ->
            User.list { sort: 'username', direction: 'desc' }, (err, users) ->
                should.not.exist err
                users.length.should.eql 2
                users[0].username.should.eql 'username_2'
                users[1].username.should.eql 'username_1'
                User.clear next

    it 'Test list # where', (next) ->
        User.create [
            { username: 'username_1', email: '1@email.com', password: 'my_password' }
            { username: 'username_2', email: '2@email.com', password: 'my_password' }
            { username: 'username_3', email: '1@email.com', password: 'my_password' }
        ], (err, users) ->
            User.list { email: '1@email.com', direction: 'desc' }, (err, users) ->
                should.not.exist err
                users.length.should.eql 2
                users[0].username.should.eql 'username_3'
                users[1].username.should.eql 'username_1'
                User.clear next

    it 'Test list # where union, same property', (next) ->
        User.create [
            { username: 'username_1', email: '1@email.com', password: 'my_password' }
            { username: 'username_2', email: '2@email.com', password: 'my_password' }
            { username: 'username_3', email: '1@email.com', password: 'my_password' }
            { username: 'username_4', email: '4@email.com', password: 'my_password' }
        ], (err, users) ->
            User.list { email: ['1@email.com', '4@email.com'], operation: 'union', direction: 'desc' }, (err, users) ->
                should.not.exist err
                users.length.should.eql 3
                users[0].username.should.eql 'username_4'
                users[1].username.should.eql 'username_3'
                users[2].username.should.eql 'username_1'
                User.clear next

    it 'Test list # where inter, same property', (next) ->
        User.create [
            { username: 'username_1', email: '1@email.com', password: 'my_password', name: 'name_1' }
            { username: 'username_2', email: '2@email.com', password: 'my_password', name: 'name_2' }
            { username: 'username_3', email: '1@email.com', password: 'my_password', name: 'name_3' }
            { username: 'username_4', email: '4@email.com', password: 'my_password', name: 'name_4' }
        ], (err, users) ->
            User.list { email: '1@email.com', name: 'name_3', operation: 'inter', direction: 'desc' }, (err, users) ->
                should.not.exist err
                users.length.should.eql 1
                users[0].username.should.eql 'username_3'
                User.clear next
