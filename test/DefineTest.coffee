
assert = require 'assert'

config = require '../conf/test'
ron = require '../index'

module.exports = 
    'Define # new schema # string': (next) ->
        client = ron config
        user = client.define 'user'
        assert.ok user instanceof ron.Table
        assert.eql user, client.user
        client.quit next
    'Define # new schema # object': (next) ->
        client = ron config
        user = client.define name: 'user'
        assert.eql user, client.user
        assert.ok user instanceof ron.Table
        client.quit next
    'Define # identifier': (next) ->
        client = ron config
        user = client.define name: 'user'
        assert.eql user.identifier('id'), user
        assert.eql 'id', user.identifier()
        client.quit next
    'Define # index': (next) ->
        client = ron config
        user = client.define name: 'user'
        assert.eql user.identifier('my_id'), user
        assert.eql 'my_id', user.identifier()
        client.quit next
    'Define # index': (next) ->
        client = ron config
        user = client.define name: 'user'
        assert.eql user.index('my_index'), user
        assert.eql ['my_index'], user.index()
        client.quit next
    'Define # unique': (next) ->
        client = ron config
        user = client.define name: 'user'
        assert.eql user.unique('my_unique'), user
        assert.eql ['my_unique'], user.unique()
        client.quit next
    'Define # property': (next) ->
        client = ron config
        user = client.define name: 'user'
        # Define properties
        assert.eql user.property('id', identifier: true), user
        assert.eql user.property('username', unique: true), user
        assert.eql user.property('email', { index: true, email: true }), user
        assert.eql user.property('name', {}), user
        # Retrieve properties
        assert.eql user.property('id'), { name: 'id', identifier: true }
        assert.eql user.property('username'), { name: 'username', unique: true }
        assert.eql user.property('email'), { name: 'email', index: true, email: true }
        assert.eql user.property('name'), { name: 'name' }
        
        client.quit next
        
