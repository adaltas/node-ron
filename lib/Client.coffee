
redis = require('redis')
Table = require('./Table')

module.exports = class Client

    constructor: (options = {}) ->
        @options = options
        @name = options.name or 'ron'
        if @options.redis
            @redis = @options.redis
        else
            @redis = redis.createClient options.redis_port, options.redis_host
            @redis.auth options.redis_password if options.redis_password?
            @redis.select options.redis_database if options.redis_database?

    create: (options) ->
        new Table @, options

    quit: ->
        @redis.quit()
    
    quit: (callback) ->
        @redis.quit (err, status) ->
            return callback err if err
            callback null, status if callback
