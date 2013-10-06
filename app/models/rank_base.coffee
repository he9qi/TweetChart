redis = require('redis').createClient()#"6379", "67.207.155.14"
_     = require 'underscore'

class RankBase
  
  constructor: (attributes) ->
    @[key] = value for key,value of attributes
    
  # get ranks by time
  @lastByTime: (rank_class, timestamp, interval, step, callback) ->
    timestamps = _.range timestamp-(interval-step), timestamp+step, step
    redis.hmget rank_class.key(), timestamps, (err, objects) ->
      rus = []
      for key, value of objects
        ru = new rank_class _.extend JSON.parse(value), {"timestamp" : timestamps[key]}
        rus.push ru
      callback null, rus, RankBase.rankName(rank_class.name)
  
  
  # get rank name by class name
  @rankName: (class_name) ->
    class_name.toLowerCase().split("rank")[1]
      
      
  # get all ranks by time
  @lastAllByTime: (rank_class_array, timestamp, interval, step, callback) ->
    ranks = {}
    for rc, i in rank_class_array
      rc.lastByTime timestamp, interval, step, (err, _data, json_name) =>
        # add current class data
        current_class_name = rank_class_array[rank_class_array.length-1].name
        ranks[json_name]   = _data
        # if the class is the last one, return
        if RankBase.rankName(current_class_name) is json_name
          callback null, ranks
        
      
module.exports = RankBase