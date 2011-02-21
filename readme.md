
Redis ORM for NodeJs
====================

Be carefull, this project is experimental.

The library provide
-------------------

*	Simple & tested API
*	Unique index keys

Quick exemple
-------------

	var ron = require('ron');
	
	var Users = ron.create('Users')
	// A unique property identifier, default to id
	.identify('id_user')
	// Create a unique index
	.unique('username')
	// Create an index
	.index('lastname');
	
	Users.put({
		username: 'my_username',
		lastname: 'My Lastname'
	}, function(err, user){
		Users.get(user.id_user, function(err, user){
			Users.delete(user.id_user, function(err){
				console.log(user.id_user + ' created and then removed');
			})
		})
	})

Implementation
--------------

Unique identifiers are incremented from a string:

	count:{Model}

Model identifiers are indexed in a set:

	index:{model}

Unique indexes are stored in a hash with keys as identifier:

	index:{model}:{property}

Object data are stored in a hash

	obj:{model}:{id}

Run tests
---------

The test suite is integrated with *expresso* and should be run synchronously since they share the same redis client. 

To run the tests, simply start redis `redis-server ./conf/redis.conf` and type `expresso -s` inside the project folder.

