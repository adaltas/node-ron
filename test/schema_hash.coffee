
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'client', ->

  client = null

  before (next) ->
    client = ron config
    next()
  
  after (next) ->
    client.quit next

  it 'init', (next) ->
    next()

  it 'should hash a string', (next) ->
    client.get('users').hash('1').should.eql '356a192b7913b04c54574d18c28d46e6395428ab'
    next()

  it 'should hash a number', (next) ->
    client.get('users').hash(1).should.eql '356a192b7913b04c54574d18c28d46e6395428ab'
    next()
