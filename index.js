
require('coffee-script');

var Client = require('./lib/Client');

var Records  = require('./lib/Records');

module.exports = function(options){
    return new Client(options);
};

module.exports.Client = Client;

module.exports.Records = Records;
