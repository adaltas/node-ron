
ron = require('..');
// Client connection
client = ron({
  port: 6379,
  host: '127.0.0.1',
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
);
