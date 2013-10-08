redis = require('redis').createClient()
Base  = require './base'

class User extends Base

  @key: ->
    "ds:tweets:users"

module.exports = User