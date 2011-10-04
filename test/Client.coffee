
assert = require 'assert'

config = require '../conf/test'
Ron = require '../index'

ron = Ron config

module.exports =
    'init': (exit) ->
        exit()
    'Test hash # with string': (exit) ->
        assert.eql ron.hash('1'), '356a192b7913b04c54574d18c28d46e6395428ab'
        exit()
    'Test hash # with number': (exit) ->
        assert.eql ron.hash(1), '356a192b7913b04c54574d18c28d46e6395428ab'
        exit()
    'destroy': (exit) ->
        ron.quit exit
