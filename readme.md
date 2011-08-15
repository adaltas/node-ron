
Redis ORM for NodeJs
====================

Ad-lib, be carefull, this project is experimental.

The library provide
-------------------

*	Simple & tested API
*   Sortable indexes and unique values
*   Records are pure object, no extended class, no magic properties
*   Code, tests and readme written in coffescript, samples written in javascript

Quick exemple
-------------

	ron = require 'ron'
	app = ron
		host: ''
		port: ''
        name: 'auth'
	
	User = app.create 'users'
    User.property 'id',
        identifier: true
    # Use a hash index
	User.property 'username',
		type: 'string'
		unique: true
    # Use a sorted set index
    User.property 'email',
		type: 'string'
		index: true

Client API
----------

*   Client::constructor
*   Client::quit

Schema API
----------

*   Records::property
*   Records::identifier
*   Records::unique
*   Records::index

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

Start a redis server on the default port
	redis-server ./conf/redis.conf

Note, the current configuration fit a 2.9.0 redis version

Run the test suite with *expresso*:
	expresso -s


