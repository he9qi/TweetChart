redis = require('redis').createClient()
_     = require 'underscore'

class Trend
  
  # { 
  #   name : "word", 
  #   values : 
  #     [ time : 3919321, value :123 ] 
  # }
  constructor: (attributes) ->
    @[key] = value for key,value of attributes
  
    
  save: (callback) ->  
    @generateId()
    redis.hset Trend.key(), @id, JSON.stringify(@), (err, responseCode) =>
      callback null, @
      
  destroy: (callback) ->
    redis.hdel Trend.key(), @id, (err) ->
      callback err if callback
      
  generateId: ->
    if not @id and @name
      @id = Trend.idByName @name
          
  @idByName: (name) ->
    name.replace /\s/g, '-'        
          
  # table key name  
  @key: ->
    "Trend:#{process.env.NODE_ENV}"
    
    
  # get all the word trends
  @all: (callback) ->
    redis.hgetall Trend.key(), (err, objects) ->
      trends = []
      for key, value of objects
        trend = new Trend JSON.parse(value)
        trends.push trend
      callback null, trends
    
    
  # add by data which has format of :
  # { 
  #   "rankings"  : [ ["#word1", 13], ["word2", 14] ], 
  #   "timestamp" : 424255223 
  # }  
  @addData: (data, callback) ->
    return unless data
    rankings  = data.rankings
    timestamp = data.timestamp
    
    _.each rankings, (ranking) =>
      Trend.addOrUpdate timestamp, ranking, (exists, json) ->
        # console.log "trend exists ? => #{exists}"
    callback() if callback
  
  # based on the ranking information i.e. word and count, 
  # add or update trends
  @addOrUpdate: (time, ranking, callback) ->
    name  = ranking[0]
    value = ranking[1]
    id    = Trend.idByName name
      
    Trend.getById id, (err, trend) ->
      if err isnt null
        trend = new Trend { "name" : name, "values" : [{ time, value }] }
        trend.save (err, json) ->
          callback false, trend
      else
        trend.values.push { time, value }
        trend.save (err, json) ->
          callback true, trend
          
  # get trend by name, if trend is not found, send callback with error
  # else send with trend object 
  @getById: (id, callback) ->
    redis.hget Trend.key(), id, (err, json) ->
      # callback err, json
      if json is null
        callback new Error("Trend '#{id}' could not be found.")
      else
        trend = new Trend JSON.parse(json)
        callback null, trend
    
  # destroy all the data        
  @destroyAll: ->
    redis.del Trend.key()
            
module.exports = Trend