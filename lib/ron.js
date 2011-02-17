
var redis = require('redis'),
	Model = require('./Model');

var ron = {};

ron.Model = Model;

ron.client = function(client){
	if(!ron._client){
		ron._client = client||redis.createClient();
	}
	return ron._client;
}

ron.create = function(name){
	return ron[name] = new Model(this, name);
}

ron.quit = function(name){
	if(ron._client){
		ron._client.quit();
		delete ron._client;
	}
}

module.exports = ron;
