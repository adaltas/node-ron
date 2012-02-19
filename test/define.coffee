
should = require 'should'

config = require '../conf/test'
ron = require '..'

describe 'define', ->

    it 'Define # new schema # string', (next) ->
        client = ron config
        user = client.define 'user'
        user.should.be.instanceof ron.Table
        user.should.eql client.get 'user'
        client.quit next

    it 'Define # new schema # object', (next) ->
        client = ron config
        user = client.define name: 'user'
        user.should.eql client.get 'user'
        user.should.be.instanceof ron.Table
        client.quit next

    it 'Define # identifier', (next) ->
        client = ron config
        user = client.define name: 'user'
        user.should.eql user.identifier('id')
        user.identifier().should.eql 'id'
        client.quit next

    it 'Define # index', (next) ->
        client = ron config
        user = client.define name: 'user'
        user.should.eql user.index('my_index')
        ['my_index'].should.eql user.index()
        client.quit next

    it 'Define # unique', (next) ->
        client = ron config
        user = client.define name: 'user'
        user.should.eql user.unique('my_unique')
        user.unique().should.eql ['my_unique']
        client.quit next

    it 'Define # property', (next) ->
        client = ron config
        user = client.define name: 'user'
        # Define properties
        user.should.eql user.property('id', identifier: true)
        user.should.eql user.property('username', unique: true)
        user.should.eql user.property('email', { index: true, email: true })
        user.should.eql user.property('name', {})
        # Retrieve properties
        user.property('id').should.eql { name: 'id', identifier: true, type: 'int' }
        user.property('username').should.eql { name: 'username', unique: true }
        user.property('email').should.eql { name: 'email', index: true, email: true }
        user.property('name').should.eql { name: 'name' }
        
        client.quit next

        
