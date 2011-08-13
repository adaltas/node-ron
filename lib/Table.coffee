
isEmail = (email) ->
    /^[a-z0-9,!#\$%&'\*\+\/\=\?\^_`\{\|}~\-]+(\.[a-z0-9,!#\$%&'\*\+\/\=\?\^_`\{\|}~\-]+)*@[a-z0-9\-]+(\.[a-z0-9\-]+)*\.([a-z]{2,})$/.test(email)

module.exports = class Table

    redis = null
    name = null
    db = null
    identifier = null
    
    properties: {}
    indexes: {}

    constructor: (ron, options) ->
        redis = ron.redis
        options = {name: options} if typeof options is 'string'
        db = ron.name
        name = options.name
        
    ###
    Define a new property.
    ###
    property: (property, options) ->
        @properties[property] = options
        @indentifier property if property.identifier
        
    ###
    Define a property as an identifier.
    -----------------------------------
    An identifier is a property which uniquely define a record.
    Internaly, those type of property are stored in set.
    ###
    identifier: (property) ->
        # Set the property
        if property?
            @properties[property] = {} unless @properties[property]?
            @properties[property].identifier = true
            identifier = property
        # Get the property
        else
            throw new Error 'No defined identifier' unless @indexes.identifier
            identifier
    
    ###
    Return all records
    ------------------
    Similar to the find method with far less options and a faster implementation.
    ###
    all: (callback) ->
        redis.smembers "#{db}:#{name}_#{identifier}", (err, recordIds) ->
            multi = redis.multi()
            for recordId in recordIds
                multi.hgetall "#{db}:#{name}:#{recordId}"
            multi.exec (err, users) ->
                return callback err if err
                callback null, users
    
    ###
    Clear all the records and return the number of removed records
    ###
    clear: (callback) ->
        redis.smembers "#{db}:#{name}_#{identifier}", (err, recordIds) ->
            return callback err if err
            multi = redis.multi()
            # delete objects
            for recordId in recordIds
                multi.del "#{db}:#{name}:#{recordId}" 
            # delete identifier indexes
            multi.del "#{db}:#{name}_incr"
            multi.del "#{db}:#{name}_#{identifier}"
            # delete indexes
            multi.del "#{db}:#{name}_email"
            multi.del "#{db}:#{name}_username"
            multi.exec (err, results) ->
                return callback err if err
                callback null, recordIds.length
    
    ###
    Count the number of records present in the database.
    ###
    count: (callback) ->
        redis.scard "#{db}:#{name}_#{identifier}", (err, count) ->
            return callback err if err
            callback null, count
    
    ###
    Create a new record.
    ###
    create: (records, callback) ->
        isArray = Array.isArray records
        records = [records] if ! isArray
        # Sanitize records
        for record in records
            # Validation check
            if not record.email? or typeof record.email isnt 'string' or not isEmail record.email
                return callback new Error 'Email missing or invalid'
            if not record.username or typeof record.username isnt 'string'
                return callback new Error 'Username missing or invalid'
        # Persist
        @exists records, (err, recordIds) ->
            return callback err if err
            for recordId in recordIds
                return callback new Error "User #{recordId} already exists" if recordId?
            multi = redis.multi()
            multi.incr "#{db}:#{name}_incr" for x in records
            multi.exec (err, recordIds) ->
                return callback err if err
                multi = redis.multi()
                for record, i in records
                    record[identifier] = recordId = recordIds[i]
                    multi.sadd "#{db}:#{name}_#{identifier}", recordId
                    multi.hset "#{db}:#{name}_email", record.email, recordId
                    multi.hset "#{db}:#{name}_username", record.username, recordId if record.username
                    multi.hmset "#{db}:#{name}:#{recordId}", record
                multi.exec (err, results) ->
                    return callback err if err
                    for result in results
                        return callback new Error 'Corrupted user database ' if result[0] is not "0"
                    callback null, if isArray then records else records[0]
    
    ###
    Check if one or more record exist.
    ----------------------------------
    The existence of a record is based on its id or any property defined as unique.
    The return value respect the same structure as the provided records argument. Ids
    are present if the record exists or null if it doesn't.
    ###
    exists: (records, callback) ->
        isArray = Array.isArray records
        records = [records] if ! isArray
        multi = redis.multi()
        for record in records
            if typeof record is 'object'
                if record[identifier]?
                    recordId = record[identifier]
                    multi.hget "#{db}:#{name}:#{recordId}", identifier
                else if record.email?
                    multi.hget "#{db}:#{name}_email", record.email
                else if record.username?
                    multi.hget "#{db}:#{name}_username", record.username
            else
                multi.hget "#{db}:#{name}:#{record}", identifier
        multi.exec (err, recordIds) ->
            return callback err if err
            callback null, if isArray then recordIds else recordIds[0]
    
    ###
    Create or extract one or several ids.
    -------------------------------------
    The method doesn't hit the database to check the existance of an id.
    Set the provided boject to null if an id couldn't be found.
    
    todo: With no argument, generate an new id
    todo: IF first argument is a number, genererate the number of new id
    If first argument is an object or an array of object, extract the id from those objects
    Options:
    - object: return record objects instead of ids
    - accept_null: prevent error throwing if record is null
    The id will be set to null if the record wasn't discovered in the database
    ###
    id: (records, options, callback) ->
        if arguments.length is 2
            callback = options
            options = {}
        isArray = Array.isArray records
        records = [records] if not isArray
        cmds = []
        err = null
        for record, i in records
            if typeof record is 'object'
                if not record?
                    if not options.accept_null
                        return callback new Error 'Invalid object, got ' + (JSON.stringify record)
                else if record[identifier]?
                    # It's perfect, no need to hit redis
                else if record.email?
                    cmds.push ['hget', "#{db}:#{name}_email", record.email, ((record) -> (err, recordId) ->
                        record[identifier] = recordId;
                    )(record)]
                else if record.username?
                    cmds.push ['hget', "#{db}:#{name}_username", record.username, ((record) -> (err, recordId) ->
                        record[identifier] = recordId;
                    )(record)]
                else
                    return callback new Error 'Invalid object, got ' + (JSON.stringify record)
            else if typeof record is 'number'
                records[i] = {}
                records[i][identifier] = record
            else
                return callback new Error 'Invalid id, got ' + (JSON.stringify record)
        # No need to hit redis if no comand are registered
        if cmds.length is 0
            if not options.object
                records = for record in records
                    if record? then record[identifier] else record
            return callback null, if isArray then records else records[0]
        multi = redis.multi cmds
        multi.exec (err, results) ->
            if not options.object
                records = for record in records
                    record[identifier]
            callback null, if isArray then records else records[0]
    
    ###
    Retrieve a record
    -----------------
    If options is an array, it is considered to be an array of properties
    Options are
    -   properties, array of properties to fetch, all if null
    -   force, force the retrieval of properties even if already present in the record objects
    ###
    get: (records, options, callback) ->
        if arguments.length is 2
            callback = options
            options = {}
        if Array.isArray options
            options = {properties: options}
        isArray = Array.isArray records
        records = [records] if ! isArray
        @id records, {object: true}, (err, records) ->
            cmds = []
            records.forEach (record, i) ->
                if record[identifier] is null
                    records[i] = null
                else if options.properties?
                    options.properties.forEach (property) ->
                        if ! options.force and ! record[property]
                            recordId = record[identifier]
                            cmds.push ['hget', "#{db}:#{name}:#{recordId}", property, (err, value)->
                                record[property] = value
                            ]
                else
                    recordId = record[identifier]
                    cmds.push ['hgetall', "#{db}:#{name}:#{recordId}", (err, values)->
                        for property, value of values
                            record[property] = value
                    ]
            if cmds.length is 0
                return callback null, if isArray then records else records[0]
            multi = redis.multi cmds
            multi.exec (err, values) ->
                return callback err if err
                callback null, if isArray then records else records[0]
    
    list: (options, callback) ->
        if typeof options is 'function'
            callback = options
            options = {}
        properties = [ 'username', 'password' ]
        args = []
        # Index
        args.push "#{db}:#{name}_#{identifier}"
        # Sorting by one property
        if options.sort?
            args.push 'by'
            args.push "#{db}:#{name}:*->" + options.sort
        # Properties to return
        for property in properties
            args.push 'get'
            args.push "#{db}:#{name}:*->" + property
        # Sorting property is a string
        args.push 'alpha'
        # Sorting direction
        args.push options.direction ? 'asc'
        # Callback
        args.push (err, values) ->
            return callback err if err
            result = for i in [0 .. values.length - 1] by properties.length
                record = {}
                for property, j in properties
                    record[property] = values[i + j]
                record
            callback null, result
        # Run command
        redis.sort args...
    
    ###
    Remove one or several records
    ###
    remove: (records, callback) ->
        isArray = Array.isArray records
        records = [records] if ! isArray
        records = @get records, ['email', 'username'], (err, records) ->
            return callback err if err
            multi = redis.multi()
            for record in records
                # delete objects
                recordId = record[identifier]
                multi.del "#{db}:#{name}:#{recordId}"
                # delete indexes
                multi.srem "#{db}:#{name}_#{identifier}", record[identifier]
                multi.hdel "#{db}:#{name}_email", record.email
                multi.hdel "#{db}:#{name}_username", record.username
            multi.exec (err, results) ->
                return callback err if err
                callback null, records.length
    
    ###
    Update one or several records
    ###
    update: (records, callback) ->
        isArray = Array.isArray records
        records = [records] if ! isArray
        # 1. Get values of indexed properties
        # 2. If indexed properties has changed
        #    2.1 Make sure the new property is not assigned to another record
        #    2.2 Erase old index & Create new index
        # 3. Save the record
        @id records, {object: true}, (err, records) ->
            return callback err if err
            # Stop here if a record is invalid
            for record in records
                return callback new Error 'Invalid record' unless record
            # Find records with a possible updated index
            cmdsCheck = []
            cmdsUpdate = []
            multi = redis.multi()
            for record in records
                # Stop here if we couldn't get an id
                recordId = record[identifier]
                return callback new Error 'Unsaved record' unless recordId
                cmdsUpdate.push ['hmset', "#{db}:#{name}:#{recordId}", record ]
                do (record) ->
                    # If an index has changed, we need to update it
                    changedProperties = []
                    for property in ['email', 'username']
                        changedProperties.push property if record[property]
                    return if changedProperties.length is 0
                    multi.hmget "#{db}:#{name}:#{recordId}", changedProperties, (err, values) ->
                        for property, propertyI in changedProperties
                            if values[propertyI] isnt record[property]
                                # First we check if index for new key exists to avoid duplicates
                                cmdsCheck.push ['hexists', "#{db}:#{name}users_#{property}", record[property] ]
                                # Second, if it exists, erase old key and set new one
                                cmdsUpdate.push ['hdel', "#{db}:#{name}_#{property}", values[propertyI] ]
                                cmdsUpdate.push ['hsetnx', "#{db}:#{name}_#{property}", record[property], record[identifier] ]
            # Get the value of those indexed properties to see if they changed
            multi.exec (err, values) ->
                # Check if unique properties doesn't already exists
                multi = redis.multi cmdsCheck
                multi.exec (err, exists) ->
                    return callback err if err
                    for exist in exists
                        return callback new Error 'Unique value already exists' if exist isnt 0
                    # Update properties
                    multi = redis.multi cmdsUpdate
                    multi.exec (err, exsits) ->
                        return callback err if err
                        callback null, if isArray then records else records[0]

