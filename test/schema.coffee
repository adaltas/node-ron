
    should = require 'should'

    try config = require '../conf/test' catch e
    ron = require '..'

    describe 'schema', ->

    it 'should create a schema from a name', (next) ->
        client = ron config
        Users = client.get 'users'
        Users.should.be.instanceof ron.Schema
        Users.should.be.instanceof ron.Records
        client.quit next

    it 'should create a schema from an object', (next) ->
        client = ron config
        Users = client.get name: 'users'
        Users.should.be.instanceof ron.Schema
        Users.should.be.instanceof ron.Records
        client.quit next

    it 'should define and retrieve an identifier', (next) ->
        client = ron config
        Users = client.get name: 'users'
        Users.should.eql Users.identifier('id')
        Users.identifier().should.eql 'id'
        client.quit next

    it 'should define and retrieve an index', (next) ->
        client = ron config
        Users = client.get name: 'users'
        Users.should.eql Users.index('my_index')
        ['my_index'].should.eql Users.index()
        client.quit next

    it 'Define # unique', (next) ->
        client = ron config
        Users = client.get name: 'users'
        Users.should.eql Users.unique('my_unique')
        Users.unique().should.eql ['my_unique']
        client.quit next

    it 'should define multiple properties from object', (next) ->
        client = ron config
        # Define properties
        Users = client.get
            name: 'users'
            properties: 
                id: identifier: true
                username: unique: true
                email: { index: true, email: true }
                name: {}
        # Retrieve properties
        Users.property('id').should.eql { name: 'id', identifier: true, type: 'int' }
        Users.property('username').should.eql { name: 'username', unique: true }
        Users.property('email').should.eql { name: 'email', index: true, email: true }
        Users.property('name').should.eql { name: 'name' }
        client.quit next

    it 'should define multiple properties by calling functions', (next) ->
        client = ron config
        Users = client.get name: 'users'
        # Define properties
        Users.should.eql Users.property('id', identifier: true)
        Users.should.eql Users.property('username', unique: true)
        Users.should.eql Users.property('email', { index: true, email: true })
        Users.should.eql Users.property('name', {})
        # Retrieve properties
        Users.property('id').should.eql { name: 'id', identifier: true, type: 'int' }
        Users.property('username').should.eql { name: 'username', unique: true }
        Users.property('email').should.eql { name: 'email', index: true, email: true }
        Users.property('name').should.eql { name: 'name' }
        client.quit next

        
