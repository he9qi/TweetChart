redis = require('redis').createClient()
Base  = require './base'

class Status extends Base
  
  @key: ->
    "ds:tweets:statuses"
    
module.exports = Status