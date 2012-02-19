
crypto = require('crypto')
redis = require('redis')
Table = require('./Table')

module.exports = class Client

    constructor: (options = {}) ->
        @options = options
        @name = options.name or 'ron'
        @records = []
        if @options.redis
            @redis = @options.redis
        else
            @redis = redis.createClient options.redis_port ? 6379, options.redis_host ? '127.0.0.1'
            @redis.auth options.redis_password if options.redis_password?
            @redis.select options.redis_database if options.redis_database?

    define: (options) ->
        name = if typeof options is 'string' then options else options.name
        @records[name] = new Table @, options
    
    get: (type) ->
        @records[type]
    
    quit: (callback) ->
        @redis.quit (err, status) ->
            return unless callback
            return callback err if err
            callback null, status if callback
    
    hash: (key) ->
        key = "#{key}" if typeof key is 'number'
        return if key? then crypto.createHash('sha1').update(key).digest('hex') else 'null'