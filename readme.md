
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
client = ron({
    redis_port: 6379
    redis_host: '127.0.0.1'
    name: 'auth'
});
users = client.define('users');
users.property('id', {identifier: true});
users.property('username', {unique: true});
users.property('email', {index: true, email: true});
users.property('name', {});
```

The library provide
-------------------

*	Simple & tested API
*   Sortable indexes and unique values
*   Records are pure object, no extended class, no magic properties

Client API
----------

*   Client::constructor
*   Client::quit
*   Client::define

Schema API
----------

*   Records::property
*   Records::identifier
*   Records::index
*   Records::unique
*   Records::email

Record API
----------

*   Records::all
*   Records::count
*   Records::create
*   Records::exists
*   Records::get
*   Records::id
*   Records::list
*   Records::remove
*   Records::update

Run tests
---------

Start a redis server (tested against version 2.9.0) on the default port
```bash
redis-server ./conf/redis.conf
```

Run the test suite with *expresso*:
```bash
expresso -s
```


