
require('coffee-script');

var Client = require('./lib/Client');

module.exports = function(options){
    return new Client(options);
};

module.exports.Client = Client;

module.exports.Records = require('./lib/Records');

module.exports.Schema = require('./lib/Schema');
