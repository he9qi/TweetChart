redis = require('redis').createClient()
_     = require 'underscore'

class RankBase
  
  constructor: (attributes) ->
    @[key] = value for key,value of attributes
    
  @modelClass: ->
    null
    
    
  # get ranks by time
  @lastByTime: (rank_class, timestamp, interval, step, callback) ->
    timestamps = _.range timestamp-(interval-step), timestamp+step, step
    redis.hmget rank_class.key(), timestamps, (err, objects) ->
      rts = []
      ids = []
      for key, value of objects
        ru = new rank_class _.extend JSON.parse(value), {"timestamp" : timestamps[key]}
        rts.push ru
        ids.push _.map ru.ranks, (d) -> d.id
      ids = _.uniq (_.flatten ids)   
      
      # put ids to models in the last item
      modelClass = rank_class.modelClass()
      if modelClass != null
        modelClass.getByIds ids, (err, _statuses) ->
          rts[rts.length-1]['models'] = {}
          for i, _status of _statuses
            unless _status['id'] is undefined 
              rts[rts.length-1].models[_status.id] = _status
          callback err, rts, rank_class
      else
        callback err, rts, rank_class
          
          
      
  # get all ranks by time
  @lastAllByTime: (rank_class_array, timestamp, interval, step, callback) ->
    ranks = {}
    counter = 0
    for rc, i in rank_class_array
      rc.lastByTime timestamp, interval, step, (err, _data, _rank_class) =>
        
        # add current class data
        counter = counter + 1
        ranks[ _rank_class.rankName() ] = _data

        # if the class is the last one, return
        callback null, ranks if counter >= rank_class_array.length
          
          
          
  # get rank name by class name
  @rankName: ->
    @name.toLowerCase().split("rank")[1]        
      
module.exports = RankBase