
var redis = require('redis'),
	Model = require('./Model');

var orm = {};

orm.client = function(client){
	if(!orm._client){
		orm._client = client||redis.createClient();
	}
	return orm._client;
}

orm.create = function(name){
	return orm[name] = new Model(this, name);
}

orm.quit = function(name){
	if(orm._client){
		orm._client.quit();
		delete orm._client;
	}
}

module.exports = orm;
