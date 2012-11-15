---
language: en
layout: page
title: "Redis ORM for NodeJs"
date: 2012-03-10T15:16:01.006Z
comments: false
sharing: false
footer: false
navigation: ron
github: https://github.com/wdavidw/node-ron
---

Redis ORM for NodeJs
====================

Installation
------------

```bash
npm install ron
```

Usage
-----

```javascript
ron = require('ron');
// Client connection
client = ron({
  port: 6379
  host: '127.0.0.1'
  name: 'auth'
});
// Schema definition
Users = client.get('users');
Users.property('id', {identifier: true});
Users.property('username', {unique: true});
Users.property('email', {index: true, type: 'email'});
Users.property('name', {});
// Record manipulation
Users.create(
  {username: 'ron', email: 'ron@domain.com'},
  function(err, user){
    console.log(err, user.id);
  }
)
```

The library provides
--------------------

*	  Documented and tested API
*   Records access with indexes and unique values
*   Records are pure object, no extended class, no magic

Client API
----------

*   [Client::constructor](client.html#ron)
*   [Client::get](client.html#get)
*   [Client::quit](client.html#quit)

Schema API
----------

*   [Records::hash](schema.html#hash)
*   [Records::identifier](schema.html#identifier)
*   [Records::index](schema.html#index)
*   [Records::property](schema.html#property)
*   [Records::name](schema.html#name)
*   [Records::serialize](schema.html#serialize)
*   [Records::temporal](schema.html#temporal)
*   [Records::unique](schema.html#unique)
*   [Records::unserialize](schema.html#unserialize)
*   [Records::validate](schema.html#validate)

Records API
-----------

*   [Records::all](records.html#all)
*   [Records::clear](records.html#clear)
*   [Records::count](records.html#count)
*   [Records::create](records.html#create)
*   [Records::exists](records.html#exists)
*   [Records::get](records.html#get)
*   [Records::id](records.html#id)
*   [Records::list](records.html#list)
*   [Records::remove](records.html#remove)
*   [Records::update](records.html#update)

Run tests
---------

Start a redis server on the default port
```bash
redis-server ./conf/redis.conf
```

Run the tests with mocha:
```bash
make test
```


