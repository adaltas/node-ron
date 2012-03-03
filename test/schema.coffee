
    should = require 'should'

    try config = require '../conf/test' catch e
    ron = require '..'

    describe 'schema', ->

    it 'should create a schema from a name', (next) ->
        client = ron config
        schema = client.schema 'users'
        schema.should.be.instanceof ron.Schema
        client.quit next

    it 'should create a schema from an object', (next) ->
        client = ron config
        schema = client.schema name: 'users'
        schema.should.be.instanceof ron.Schema
        client.quit next

    it 'should define and retrieve an identifier', (next) ->
        client = ron config
        schema = client.schema name: 'users'
        schema.should.eql schema.identifier('id')
        schema.identifier().should.eql 'id'
        client.quit next

    it 'should define and retrieve an index', (next) ->
        client = ron config
        schema = client.schema name: 'users'
        schema.should.eql schema.index('my_index')
        ['my_index'].should.eql schema.index()
        client.quit next

    it 'Define # unique', (next) ->
        client = ron config
        schema = client.schema name: 'users'
        schema.should.eql schema.unique('my_unique')
        schema.unique().should.eql ['my_unique']
        client.quit next

    it 'should define multiple properties from object', (next) ->
        client = ron config
        # Define properties
        schema = client.schema
            name: 'users'
            properties: 
                id: identifier: true
                username: unique: true
                email: { index: true, email: true }
                name: {}
        # Retrieve properties
        schema.property('id').should.eql { name: 'id', identifier: true, type: 'int' }
        schema.property('username').should.eql { name: 'username', unique: true }
        schema.property('email').should.eql { name: 'email', index: true, email: true }
        schema.property('name').should.eql { name: 'name' }
        client.quit next

    it 'should define multiple properties by calling functions', (next) ->
        client = ron config
        schema = client.schema name: 'users'
        # Define properties
        schema.should.eql schema.property('id', identifier: true)
        schema.should.eql schema.property('username', unique: true)
        schema.should.eql schema.property('email', { index: true, email: true })
        schema.should.eql schema.property('name', {})
        # Retrieve properties
        schema.property('id').should.eql { name: 'id', identifier: true, type: 'int' }
        schema.property('username').should.eql { name: 'username', unique: true }
        schema.property('email').should.eql { name: 'email', index: true, email: true }
        schema.property('name').should.eql { name: 'name' }
        client.quit next

        
