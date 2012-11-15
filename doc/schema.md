---
language: en
layout: page
title: "
Schema definition"
date: 2012-11-15T21:39:55.922Z
comments: false
sharing: false
footer: false
navigation: ron
github: https://github.com/wdavidw/node-ron
---


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
```coffeescript

ron.get 'users', properties: 
  user_id: identifier: true
  username: unique: true
  password: true

```
Define a schema with a declarative approach:   
```coffeescript

Users = ron.get 'users'
Users.indentifier 'user_id'
Users.unique 'username'
Users.property 'password'

```
Whichever your style, you can then manipulate your records:   
```coffeescript

users = ron.get 'users'
users.list (err, users) -> console.log users
```

<a name="hash"></a>
`hash(key)`
-------------
Utility function used when a redis key is created out of 
uncontrolled character (like a string instead of an int).


<a name="identifier"></a>
`identifier(property)`
------------------------
Define a property as an identifier or return the record identifier if
called without any arguments. An identifier is a property which uniquely 
define a record. Inside Redis, identifier values are stored in set.   


<a name="index"></a>
`index([property])`
-------------------
Define a property as indexable or return all index properties. An 
indexed property allow records access by its property value. For example,
when using the `list` function, the search can be filtered such as returned
records match one or multiple values.   

Calling this function without any argument will return an array with all the 
indexed properties.   

Example:
```coffeescript

User.index 'email'
User.list { filter: { email: 'my@email.com' } }, (err, users) ->
  console.log 'This user has the following accounts:'
  for user in user
    console.log "- #{user.username}"
```


<a name="property"></a>
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
```coffeescript

User.property 'id', identifier: true
User.property 'username', unique: true
User.property 'email', { index: true, type: 'email' }
User.property 'name', {}
```


<a name="name"></a>
`name()`
--------
Return the schema name of the current instance.

Using the function :
```coffeescript
Users = client 'users', properties: username: unique: true
console.log Users.name() is 'users'
```


<a name="serialize"></a>
`serialize(records)`
--------------------
Cast record values before their insertion into Redis.

Take a record or an array of records and update values with correct 
property types.


<a name="temporal"></a>
`temporal([options])` 
---------------------
Define or retrieve temporal definition. Marking a schema as 
temporal will transparently add two new date properties, the 
date when the record was created (by default "cdate"), and the date 
when the record was last updated (by default "mdate").


<a name="unique"></a>
`unique([property])`
--------------------
Define a property as unique or retrieve all the unique properties if no 
argument is provided. An unique property is similar to a index
property but the index is stored inside a Redis hash. In addition to being 
filterable, it could also be used as an identifer to access a record.

Example:
```coffeescript

User.unique 'username'
User.get { username: 'me' }, (err, user) ->
  console.log "This is #{user.username}"
```


<a name="unserialize"></a>
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


<a name="validate"></a>
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

