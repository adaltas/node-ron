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
Users.property('email', {index: true, email: true});
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
*   Records are pure object, no extended class, no magic

Client API
----------

*   Client::constructor
*   Client::quit
*   Client::define

Schema API
----------

*   Records::email
*   Records::hash
*   Records::identifier
*   Records::index
*   Records::property
*   Records::name
*   Records::serialize
*   Records::temporal
*   Records::unique
*   Records::unserialize
*   Records::validate

Record API
----------

*   Records::all
*   Records::clear
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

Start a redis server on the default port
```bash
redis-server ./conf/redis.conf
```

Run the tests with mocha:
```bash
make test
```


