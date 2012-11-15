[![Build Status](https://secure.travis-ci.org/wdavidw/node-ron.png)](http://travis-ci.org/wdavidw/node-ron)

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

The library provide
-------------------

*	Documented and tested API
*   Records access with indexes and unique values
*   Records are pure object, no state, no magic

Client API
----------

*   [Client::constructor](http://www.adaltas.com/projects/node-ron/client.html#ron)
*   [Client::get](http://www.adaltas.com/projects/node-ron/client.html#get)
*   [Client::quit](http://www.adaltas.com/projects/node-ron/client.html#quit)

Schema API
----------

*   [Records::hash](http://www.adaltas.com/projects/node-ron/schema.html#hash)
*   [Records::identifier](http://www.adaltas.com/projects/node-ron/schema.html#identifier)
*   [Records::index](http://www.adaltas.com/projects/node-ron/schema.html#index)
*   [Records::property](schema.html#property)
*   [Records::name](http://www.adaltas.com/projects/node-ron/schema.html#name)
*   [Records::serialize](http://www.adaltas.com/projects/node-ron/schema.html#serialize)
*   [Records::temporal](http://www.adaltas.com/projects/node-ron/schema.html#temporal)
*   [Records::unique](http://www.adaltas.com/projects/node-ron/schema.html#unique)
*   [Records::unserialize](http://www.adaltas.com/projects/node-ron/schema.html#unserialize)
*   [Records::validate](http://www.adaltas.com/projects/node-ron/schema.html#validate)

Records API
-----------

*   [Records::all](http://www.adaltas.com/projects/node-ron/records.html#all)
*   [Records::clear](http://www.adaltas.com/projects/node-ron/records.html#clear)
*   [Records::count](http://www.adaltas.com/projects/node-ron/records.html#count)
*   [Records::create](http://www.adaltas.com/projects/node-ron/records.html#create)
*   [Records::exists](http://www.adaltas.com/projects/node-ron/records.html#exists)
*   [Records::get](http://www.adaltas.com/projects/node-ron/records.html#get)
*   [Records::id](http://www.adaltas.com/projects/node-ron/records.html#id)
*   [Records::list](http://www.adaltas.com/projects/node-ron/records.html#list)
*   [Records::remove](http://www.adaltas.com/projects/node-ron/records.html#remove)
*   [Records::update](http://www.adaltas.com/projects/node-ron/records.html#update)

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


