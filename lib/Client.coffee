
redis = require 'redis'
Schema = require './Schema'
Records = require './Records'

module.exports = class Client

    constructor: (options = {}) ->
        @options = options
        @name = options.name or 'ron'
        @schemas = {}
        @records = {}
        if @options.redis
            @redis = @options.redis
        else
            @redis = redis.createClient options.redis_port ? 6379, options.redis_host ? '127.0.0.1'
            @redis.auth options.redis_password if options.redis_password?
            @redis.select options.redis_database if options.redis_database?

    # schema: (options) ->
    #     name = if typeof options is 'string' then options else options.name
    #     @schemas[name] = new Schema @, options
    #     @records[name] = new Records @, @schemas[name]
    #     @schemas[name]
    
    get: (options) ->
        # @records[name]
        name = if typeof options is 'string' then options else options.name
        @records[name] = new Records @, options if typeof options isnt 'string' or not @records[name]?
        @records[name]
    
    quit: (callback) ->
        @redis.quit (err, status) ->
            return unless callback
            return callback err if err
            callback null, status if callback