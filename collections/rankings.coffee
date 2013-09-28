redis = require('redis').createClient()
_     = require 'underscore'

class Rankings
  @key: ->
    "Rankings:#{process.env.NODE_ENV}"
    
  @all: ->
      
    
  addData: (data) ->
    return unless data
    rankings  = data.rankings
    timestamp = data.timestamp
    _.each rankings, (ranking) =>
      @addOrUpdate timestamp, ranking
      
  addOrUpdate: (time, ranking) ->
    name  = ranking[0]
    value = ranking[1]
      
    redis.hget Rankings.key(), name, (err, json) ->
      if json is null
        values = [{ time, value }]
        redis.hset Rankings.key(), name, JSON.stringify(values), (err, code) =>
          console.log @
      else
        console.log json
        
    # model = _.find @models, (model) ->
    #   name is model.name
    # 
    # if !!model
    #   model.values.push { time, value }
    # else
    #   @models.push { "name":name, "values": [{ time, value }] }
  
module.exports = Rankings