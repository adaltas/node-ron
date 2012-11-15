---
language: en
layout: page
title: "
Client connection"
date: 2012-11-15T21:39:55.922Z
comments: false
sharing: false
footer: false
navigation: ron
github: https://github.com/wdavidw/node-ron
---


The client wraps a redis connection and provides access to records definition 
and manipulation.

Internally, Ron use the [Redis client for Node.js](https://github.com/mranney/node_redis).

<a name="ron"></a>
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
```coffeescript

ron = require 'ron'
client = ron
  host: '127.0.0.1'
  port: 6379
```


<a name="get"></a>
`get(schema)` Records definition and access
-------------------------------------------
Return a records instance. If the `schema` argument is an object, a new 
instance will be created overwriting any previously defined instance 
with the same name.

`schema`           An object defining a new schema or a string referencing a schema name.

Define a record from a object:
```coffeescript

client.get
  name: 'users'
  properties:
    user_id: identifier: true
    username: unique: true
    email: index: true

```
Define a record from function calls:
```coffeescript

Users = client.get 'users'
Users.identifier 'user_id'
Users.unique 'username'
Users.index 'email'

```
Alternatively, the function could be called with a string 
followed by multiple schema definition that will be merged.
Here is a valid example:
```coffeescript

client.get 'username', temporal: true, properties: username: unique: true
```


<a name="quit"></a>
`quit(callback)` Quit
---------------------
Destroy the redis connection.

`callback`        Received parameters are:   

*   `err`         Error object if any.   
*   `status`      Status provided by the redis driver 

