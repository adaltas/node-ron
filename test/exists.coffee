
should = require 'should'

config = require '../conf/test'
Ron = require '../index'

describe 'exists', ->

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
            should.ifError err
            callback(null, users)

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

    it 'Test exists # true # identifier', (next) ->
        create (err, users) ->
            user = users[1]
            User.exists user.user_id, (err, userId) ->
                should.not.exist err
                userId.should.eql user.user_id
                User.clear next

    it 'Test exists # true # record with identifier', (next) ->
        create (err, users) ->
            user = users[1]
            User.exists {user_id: user.user_id}, (err, userId) ->
                should.not.exist err
                userId.should.eql user.user_id
                User.clear next

    it 'Test exists # true # record with unique property stored in hash', (next) ->
        create (err, users) ->
            user = users[1]
            User.exists {username: user.username}, (err, userId) ->
                should.not.exist err
                userId.should.eql user.user_id
                User.clear next

    it 'Test exists # false # indentifier', (next) ->
        User.exists 'missing', (err, exists) ->
            should.not.exist err
            should.not.exist exists
            User.clear next

    it 'Test exists # false # record with identifier', (next) ->
        User.exists {user_id: 'missing'}, (err, exists) ->
            should.not.exist err
            should.not.exist exists
            User.clear next

    it 'Test exists # false # record with unique property stored in hash', (next) ->
        User.exists {username: 'missing'}, (err, exists) ->
            should.not.exist err
            should.not.exist exists
            User.clear next


