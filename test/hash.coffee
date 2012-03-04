
should = require 'should'

try config = require '../conf/test' catch e
Ron = require '../index'

describe 'client', ->

    ron = null

    before (next) ->
        ron = Ron config
        next()
    
    after (next) ->
        ron.quit next

    it 'init', (next) ->
        next()

    it 'should hash a string', (next) ->
        ron.get('users').hash('1').should.eql '356a192b7913b04c54574d18c28d46e6395428ab'
        next()

    it 'should hash a number', (next) ->
        ron.get('users').hash(1).should.eql '356a192b7913b04c54574d18c28d46e6395428ab'
        next()
