
redis = require 'redis'
Schema = require './Schema'
Records = require './Records'

###

Client connection
=================

The client wraps a redis connection and provides access to records definition 
and manipulation.

Internally, Ron use the [Redis client for Node.js](https://github.com/mranney/node_redis).

###
module.exports = class Client

  ###

  `ron([options])` Client creation
  --------------------------------
  
  `options`           Options properties include:   

  *   `name`          A namespace for the application, all keys with be prefixed with "#{name}:". Default to "ron"   
  *   `redis`         Provide an existing instance in case you don't want a new one to be created.   
  *   `host`          Redis hostname.   
  *   `port`          Redis port.   
  *   `password`      Redis password.   
  *   `database`      Redis database (an integer).   

  Basic example:

      ron = require 'ron'
      client = ron
        host: '127.0.0.1'
        port: 6379

  ###
  constructor: (options = {}) ->
    @options = options
    @name = options.name or 'ron'
    @schemas = {}
    @records = {}
    if @options.redis
      @redis = @options.redis
    else
      @redis = redis.createClient options.port ? 6379, options.host ? '127.0.0.1'
      @redis.auth options.password if options.password?
      @redis.select options.database if options.database?
  ###

  `get(schema)` Records definition and access
  -------------------------------------------
  Return a records instance. If the `schema` argument is an object, a new 
  instance will be created overwriting any previously defined instance 
  with the same name.

  `schema`           An object defining a new schema or a string referencing a schema name.
  
  Define a record from a object:

      client.get
        name: 'users'
        properties:
          user_id: identifier: true
          username: unique: true
          email: index: true
  
  Define a record from function calls:
  
      Users = client.get 'users'
      Users.identifier 'user_id'
      Users.unique 'username'
      Users.index 'email'

  Alternatively, the function could be called with a string 
  followed by multiple schema definition that will be merged.
  Here is a valid example:

      client.get 'username', temporal: true, properties: username: unique: true

  ###
  get: (schema) ->
    create = true
    if arguments.length > 1
      if typeof arguments[0] is 'string'
      then schema = name: arguments[0]
      else schema = arguments[0]
      for i in [1 ... arguments.length]
        for k, v of arguments[i]
          schema[k] = v
    else if typeof schema is 'string'
      schema = {name: schema}
      create = false if @records[schema.name]?
    @records[schema.name] = new Records @, schema if create
    @records[schema.name]
  ###

  `quit(callback)` Quit
  ---------------------
  Destroy the redis connection.

  `callback`        Received parameters are:   

  *   `err`         Error object if any.   
  *   `status`      Status provided by the redis driver 

  ###
  quit: (callback) ->
    @redis.quit (err, status) ->
      return unless callback
      return callback err if err
      callback null, status if callback
