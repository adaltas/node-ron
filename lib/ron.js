
var redis = require('redis'),
	Model = require('./Model');

var ron = {},
	config = {};

ron.Model = Model;

ron.configure = function(c){
	config = c;
	return this;
}

ron.client = function(client){
	if(!ron._client){
		ron._client = client||redis.createClient(config.port,config.host,config);
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
