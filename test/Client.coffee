
should = require 'should'

config = require '../conf/test'
Ron = require '../index'

describe 'client', ->

    ron = Ron config

    it 'init', (next) ->
        console.log 'ok'
        next()

    it 'Test hash # with string', (next) ->
        ron.hash('1').should.eql '356a192b7913b04c54574d18c28d46e6395428ab'
        next()

    it 'Test hash # with number', (next) ->
        ron.hash(1).should.eql '356a192b7913b04c54574d18c28d46e6395428ab'
        next()

    it 'destroy', (next) ->
        ron.quit next
