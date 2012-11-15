
crypto = require 'crypto'

isEmail = (email) ->
  /^[a-z0-9,!#\$%&'\*\+\/\=\?\^_`\{\|}~\-]+(\.[a-z0-9,!#\$%&'\*\+\/\=\?\^_`\{\|}~\-]+)*@[a-z0-9\-]+(\.[a-z0-9\-]+)*\.([a-z]{2,})$/.test(email)

###

Schema definition
=================

Schema is a mixin from which `Records` inherits. A schema is defined once 
and must no change. We dont support schema migration at the moment. The `Records`
class inherit all the properties and method of the shema.

`ron`               Reference to the Ron instance   

`options`           Schema definition. Options include:   

*   `name`          Name of the schema.   
*   `properties`    Properties definition, an object or an array.   

Record properties may be defined by the following keys:   

*   `type`          Use to cast the value inside Redis, one of `string`, `int`, `date` or `email`.   
*   `identifier`    Mark this property as the identifier, only one property may be an identifier.   
*   `index`         Create an index on the property.   
*   `unique`        Create a unique index on the property.   
*   `temporal`      Add creation and modification date transparently.   

Define a schema from a configuration object:   

    ron.get 'users', properties: 
      user_id: identifier: true
      username: unique: true
      password: true

Define a schema with a declarative approach:   

    Users = ron.get 'users'
    Users.indentifier 'user_id'
    Users.unique 'username'
    Users.property 'password'

Whichever your style, you can then manipulate your records:   

    users = ron.get 'users'
    users.list (err, users) -> console.log users

###
module.exports = class Schema

  constructor: (ron, options) ->
    @ron = ron
    options = {name: options} if typeof options is 'string'
    @data = 
      db: ron.name
      name: options.name
      temporal: {}
      properties: {}
      identifier: null
      index: {}
      unique: {}
    if options.temporal
      @temporal options.temporal
    if options.properties
      for name, value of options.properties
        @property name, value
  ###

  `hash(key)`
  -------------
  Utility function used when a redis key is created out of 
  uncontrolled character (like a string instead of an int).

  ###
  hash: (key) ->
    key = "#{key}" if typeof key is 'number'
    return if key? then crypto.createHash('sha1').update(key).digest('hex') else 'null'
  ###

  `identifier(property)`
  ------------------------
  Define a property as an identifier or return the record identifier if
  called without any arguments. An identifier is a property which uniquely 
  define a record. Inside Redis, identifier values are stored in set.   

  ###
  identifier: (property) ->
    # Set the property
    if property?
      @data.properties[property] = {} unless @data.properties[property]?
      @data.properties[property].type = 'int'
      @data.properties[property].identifier = true
      @data.identifier = property
      @
    # Get the property
    else
      @data.identifier
  ###

  `index([property])`
  -------------------
  Define a property as indexable or return all index properties. An 
  indexed property allow records access by its property value. For example,
  when using the `list` function, the search can be filtered such as returned
  records match one or multiple values.   
  
  Calling this function without any argument will return an array with all the 
  indexed properties.   
  
  Example:

      User.index 'email'
      User.list { filter: { email: 'my@email.com' } }, (err, users) ->
        console.log 'This user has the following accounts:'
        for user in user
          console.log "- #{user.username}"

  ###
  index: (property) ->
    # Set the property
    if property?
      @data.properties[property] = {} unless @data.properties[property]?
      @data.properties[property].index = true
      @data.index[property] = true
      @
    # Get the property
    else
      Object.keys(@data.index)
  ###

  `property(property, [schema])`
  ------------------------------
  Define a new property or overwrite the definition of an
  existing property. If no schema is provide, return the
  property information.   
  
  Calling this function with only the property argument will return the schema
  information associated with the property.   
  
  It is possible to define a new property without any schema information by 
  providing an empty object.   
  
  Example:   

      User.property 'id', identifier: true
      User.property 'username', unique: true
      User.property 'email', { index: true, type: 'email' }
      User.property 'name', {}

  ###
  property: (property, schema) ->
    if schema?
      schema ?= {}
      schema.name = property
      @data.properties[property] = schema
      @identifier property if schema.identifier
      @index property if schema.index
      @unique property if schema.unique
      @
    else
      @data.properties[property]
  ###

  `name()`
  --------
  Return the schema name of the current instance.

  Using the function :
      Users = client 'users', properties: username: unique: true
      console.log Users.name() is 'users'

  ###
  name: -> @data.name
  ###

  `serialize(records)`
  --------------------
  Cast record values before their insertion into Redis.

  Take a record or an array of records and update values with correct 
  property types.

  ###
  serialize: (records) ->
    {properties} = @data
    isArray = Array.isArray records
    records = [records] unless isArray
    for record, i in records
      continue unless record?
      # Convert the record
      if typeof record is 'object'
        for property, value of record
          if properties[property]?.type is 'date' and value?
            if  typeof value is 'number'
              # its a timestamp
            else if typeof value is 'string'
              if /^\d+$/.test value
                record[property] = parseInt value, 10
              else
                record[property] = Date.parse value
            else if typeof value is 'object' and value instanceof Date
              record[property] = value.getTime()
    if isArray then records else records[0]
  ###

  `temporal([options])` 
  ---------------------
  Define or retrieve temporal definition. Marking a schema as 
  temporal will transparently add two new date properties, the 
  date when the record was created (by default "cdate"), and the date 
  when the record was last updated (by default "mdate").

  ###
  temporal: (temporal) ->
    if temporal?
      if temporal is true
        temporal = 
          creation: 'cdate'
          modification: 'mdate'
      @data.temporal = temporal
      @property temporal.creation, type: 'date'
      @property temporal.modification, type: 'date'
    else 
      [ @data.temporal.creation, @data.temporal.modification ]
  ###

  `unique([property])`
  --------------------
  Define a property as unique or retrieve all the unique properties if no 
  argument is provided. An unique property is similar to a index
  property but the index is stored inside a Redis hash. In addition to being 
  filterable, it could also be used as an identifer to access a record.
  
  Example:

      User.unique 'username'
      User.get { username: 'me' }, (err, user) ->
        console.log "This is #{user.username}"

  ###
  unique: (property) ->
    # Set the property
    if property?
      @data.properties[property] = {} unless @data.properties[property]?
      @data.properties[property].unique = true
      @data.unique[property] = true
      @
    # Get the property
    else
      Object.keys(@data.unique)
  ###

  `unserialize(records, [options])`
  ---------------------------------
  Cast record values to their correct type.   
  
  Take a record or an array of records and update values with correct 
  property types.   

  `options`             Options include:   

  *   `identifiers`     Return an array of identifiers instead of the record objects.  
  *   `properties`      Array of properties to be returned.  
  *   `milliseconds`    Convert date value to milliseconds timestamps instead of `Date` objects.   
  *   `seconds`         Convert date value to seconds timestamps instead of `Date` objects.   

  ###
  unserialize: (records, options = {}) ->
    {identifier, properties} = @data
    isArray = Array.isArray records
    records = [records] unless isArray
    options.properties = [identifier] if options.identifiers
    for record, i in records
      continue unless record?
      # Convert the record
      if typeof record is 'object'
        for property, value of record
          if options.properties and options.properties.indexOf(property) is -1
            delete record[property]
            continue
          if properties[property]?.type is 'int' and value?
            record[property] = parseInt value, 10
          else if properties[property]?.type is 'date' and value?
            if /^\d+$/.test value
              value = parseInt value, 10
            else
              value = Date.parse value
            if options.milliseconds
              record[property] = value
            else if options.seconds
              record[property] = Math.round( value / 1000 )
            else record[property] = new Date value
        records[i] = record[identifier] if options.identifiers
      # By convension, this has to be an identifier but we can't check it
      else if typeof record is 'number' or typeof record is 'string'
        records[i] = parseInt record

    if isArray then records else records[0]
  ###

  `validate(records, [options])`
  ------------------------------
  Validate the properties of one or more records. Return a validation 
  object or an array of validation objects depending on the provided 
  records arguments. Keys of a validation object are the name of the invalid 
  properties and their value is a string indicating the type of error.   

  `records`             Record object or array of record objects.   

  `options`             Options include:   

  *   `throw`           Throw errors on first invalid property instead of returning a validation object.   
  *   `skip_required`   Doesn't validate missing properties defined as `required`, usefull for partial update.   

  ###
  validate: (records, options = {}) ->
    {db, name, properties} = @data
    # console.log 'records', records
    isArray = Array.isArray records
    records = [records] unless isArray
    validations = for record in records
      validation = {}
      for x, property of properties
        if not options.skip_required and property.required and not record[property.name]?
          if options.throw
          then throw new Error "Required property #{property.name}"
          else validation[property.name] = 'required'
        else if property.type is 'email' and not isEmail record[property.name]
          if options.throw
          then throw new Error "Invalid email #{record[property.name]}"
          else validation[property.name] = 'invalid_email'
      validation
    if isArray then validations else validations[0]

