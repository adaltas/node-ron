
Redis ORM for NodeJs
====================

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
