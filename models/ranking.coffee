redis = require('redis').createClient()
_     = require 'underscore'

class Ranking
  
  constructor: (attributes) ->
    @[key] = value for key,value of attributes
  
module.exports = Ranking