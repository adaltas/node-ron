---
language: en
layout: page
title: "
Records access and manipulation"
date: 2012-11-15T21:39:55.923Z
comments: false
sharing: false
footer: false
navigation: ron
github: https://github.com/wdavidw/node-ron
---


Implement object based storage with indexing support.   

Identifier
----------

Auto generated identifiers are incremented integers. The next identifier is obtained from
a key named as `{s.db}:{s.name}_incr`. All the identifiers are stored as a Redis set in 
a key named as `{s.db}:{s.name}_#{identifier}`.   

Data
----

Records data is stored as a single hash named as `{s.db}:{s.name}:{idenfitier}`. The hash
keys map to the record properties and the hash value map to the values associated with
each properties.   

Regular indexes
---------------

Regular index are stored inside multiple sets, named as
`{s.db}:{s.name}_{property}:{value}`. There is one key for each indexed value and its 
associated value is a set containing all the identifiers of the records whose property
match the indexed value.   

Unique indexes
--------------

Unique indexes are stored inside a single hash key named as 
`{s.db}:{s.name}_{property}`. Inside the hash, keys are the unique values 
associated to the indexed property and values are the record identifiers.   

<a name="all"></a>
`all(callback)`
---------------
Return all records. Similar to the find method with far less options 
and a faster implementation.   


<a name="clear"></a>
`clear(callback)`
-----------------
Remove all the records and the references poiting to them. This function
takes no other argument than the callback called on error or success.   

`callback`        Received parameters are:   

*   `err`         Error object if any.   
*   `count`       Number of removed records on success   

Usage: 
```coffeescript

ron.get('users').clear (err, count) ->
  return console.error "Failed: #{err.message}" if err
  console.log "#{count} records removed"
```


<a name="count"></a>
`count(callback)`
-----------------
Count the number of records present in the database.  

Counting all the records:   
```coffeescript

Users.count, (err, count) ->
  console.log 'count users', count

```
<a name="count"></a>
`count(property, values, callback)`
----------------------------------
Count the number of one or more values for an indexed property.  

Counting multiple values:   
```coffeescript

Users.get 'users', properties:
  user_id: identifier: true
  job: index: true
Users.count 'job' [ 'globtrotter', 'icemaker' ], (err, counts) ->
  console.log 'count globtrotter', counts[0]
  console.log 'count icemaker', counts[1]
```


<a name="create"></a>
`create(records, [options], callback)`
--------------------------------------
Insert one or multiple record. The records must not already exists 
in the database or an error will be returned in the callback. Only
the defined properties are inserted.

The records passed to the function are returned in the callback enriched their new identifier property.

`records`             Record object or array of record objects.   

`options`             Options properties include:   

*   `identifiers`     Return only the created identifiers instead of the records.   
*   `validate`        Validate the records.   
*   `properties`      Array of properties to be returned.   
*   `milliseconds`    Convert date value to milliseconds timestamps instead of `Date` objects.   
*   `seconds`         Convert date value to seconds timestamps instead of `Date` objects.   

`callback`            Called on success or failure. Received parameters are:   

*   `err`             Error object if any.   
*   `records`         Records with their newly created identifier.   

Records are not validated, it is the responsability of the client program calling `create` to either
call `validate` before calling `create` or to passs the `validate` options.   


<a name="exists"></a>
`exists(records, callback)`
---------------------------
Check if one or more record exist. The existence of a record is based on its 
id or any property defined as unique. The provided callback is called with 
an error or the records identifiers. The identifiers respect the same 
structure as the provided records argument. If a record does not exists, 
its associated return value is null.   

`records`           Record object or array of record objects.   

`callback`          Called on success or failure. Received parameters are:   

*   `err`           Error object if any.   
*   `identifier`    Record identifiers or null values.   


<a name="get"></a>
`get(records, [options], callback)`
-----------------------------------
Retrieve one or multiple records. Records that doesn't exists are returned as null. If 
options is an array, it is considered to be the list of properties to retrieve. By default, 
unless the `force` option is defined, only the properties not yet defined in the provided 
records are fetched from Redis.   

`options`             All options are optional. Options properties include:   

*   `properties`      Array of properties to fetch, all properties unless defined.   
*   `force`           Force the retrieval of properties even if already present in the record objects.   
*   `accept_null`     Skip objects if they are provided as null.   
*   `object`          If `true`, return an object where keys are the identifier and value are the fetched records

`callback`            Called on success or failure. Received parameters are:   

*   `err`             Error object if the command failed.   
*   `records`         Object or array of object if command succeed. Objects are null if records are not found.   

<a name="id"></a>
`id(records, callback)`
-----------------------
Generate new identifiers. The first arguments `records` may be the number
of ids to generate, a record or an array of records.


<a name="identify"></a>
`identify(records, [options], callback)`
----------------------------------------
Extract record identifiers or set the identifier to null if its associated record could not be found.   

The method doesn't hit the database to validate record values and if an id is 
provided, it wont check its existence. When a record has no identifier but a unique value, then its
identifier will be fetched from Redis.   

`records`             Record object or array of record objects.   

`options`             Options properties include:   

*   `accept_null`     Skip objects if they are provided as null.   
*   `object`          Return an object in the callback even if it recieve an id instead of a record.   

Use reverse index lookup to extract user ids:   
```coffeescript

Users.get 'users', properties:
  user_id: identifier: true
  username: unique: true
Users.id [
  {username: 'username_1'}
  {username: 'username_2'}
], (err, ids) ->
  should.not.exist err
  console.log ids

```
Use the `object` option to return records instead of ids:   
```coffeescript

Users.get 'users', properties:
  user_id: identifier: true
  username: unique: true
Users.id [
  1, {user_id: 2} ,{username: 'username_3'}
], object: true, (err, users) ->
  should.not.exist err
  ids = for user in users then user.user_id
  console.log ids
```


<a name="list"></a>
`list([options], callback)`
---------------------------
List records with support for filtering and sorting.   

`options`             Options properties include:   

*   `direction`       One of `asc` or `desc`, default to `asc`.   
*   `identifiers`     Return an array of identifiers instead of the record objects.  
*   `milliseconds`    Convert date value to milliseconds timestamps instead of `Date` objects.   
*   `properties`      Array of properties to be returned.   
*   `operation`       Redis operation in case of multiple `where` properties, default to `union`.   
*   `seconds`         Convert date value to seconds timestamps instead of `Date` objects.   
*   `sort`            Name of the property by which records should be ordered.   
*   `where`           Hash of property/value used to filter the query.   

`callback`            Called on success or failure. Received parameters are:   

*   `err`             Error object if any.   
*   `records`         Records fetched from Redis.   

Using the `union` operation:   
```coffeescript

Users.list
  where: group: ['admin', 'redis']
  operation: 'union'
  direction: 'desc'
, (err, users) ->
  console.log users

```
An alternative syntax is to bypass the `where` option, the exemple above
could be rewritten as:   
```coffeescript

Users.list
  group: ['admin', 'redis']
  operation: 'union'
  direction: 'desc'
, (err, users) ->
  console.log users
```


<a name="remove"></a>
`remove(records, callback)`
---------------------------
Remove one or several records from the database. The function will also 
handle all the indexes referencing those records.   

`records`           Record object or array of record objects.   

`callback`          Called on success or failure. Received parameters are:   

*   `err`           Error object if any.   
*   `removed`       Number of removed records.  

Removing a single record:   
```coffeescript

Users.remove id, (err, removed) ->
  console.log "#{removed} user removed"
```


<a name="update"></a>
`update(records, [options], callback)` 
--------------------------------------
Update one or several records. The records must exists in the database or 
an error will be returned in the callback. The existence of a record may 
be discovered through its identifier or the presence of a unique property.   

`records`           Record object or array of record objects.   

`options`           Options properties include:   

*   `validate`      Validate the records.   

`callback`          Called on success or failure. Received parameters are:   

*   `err`           Error object if any.   
*   `records`       Records with their newly created identifier.   

Records are not validated, it is the responsability of the client program to either
call `validate` before calling `update` or to passs the `validate` options.   

Updating a single record:   
```coffeescript

Users.update
  username: 'my_username'
  age: 28
, (err, user) -> console.log user
```

