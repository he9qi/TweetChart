redis = require('redis').createClient()
_     = require 'underscore'

class Base

  constructor: (attributes) ->
      @[key] = value for key,value of attributes
      
  toJson: ->
    _.omit @, ["constructor", "toJson"]
    
  @getById: (id, callback) ->
    redis.hget @key(), id, (err, json) =>
      if json is null
        callback new Error("#{@name} '#{id}' could not be found.")
      else
        callback null, new @ JSON.parse(json)
        
  @getByIds: (ids, callback) ->
    redis.hmget @key(), ids, (err, objects) =>
      rus = []
      for key, value of objects
        ru = new @ JSON.parse(value)
        rus.push ru
      callback null, rus

module.exports = Base