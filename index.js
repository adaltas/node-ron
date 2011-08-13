
require('coffee-script');

var Client = require('./lib/Client');

var Table  = require('./lib/Table');

module.exports = function(options){
    return new Client(options);
};

module.exports.Client = Client;

module.exports.Table = Table;
