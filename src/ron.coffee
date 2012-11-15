
Client = require './Client'

module.exports = (options) ->
  new Client options

module.exports.Client = Client

module.exports.Records = require './Records'

module.exports.Schema = require './Schema'
