redis = require('redis').createClient()
_     = require 'underscore'

class RankStream
  
  constructor: (attributes) ->
    @[key] = value for key,value of attributes
    
  # time is the unique key
  save: (callback) ->  
    redis.hset RankStream.key(), @timestamp, JSON.stringify(@), (err, responseCode) =>
      callback null, @
      
  destroy: (callback) ->
    redis.hdel RankStream.key(), @timestamp, (err) ->
      callback err if callback
      
  @getByTime: (time, callback) ->
    redis.hget RankStream.key(), time, (err, json) ->
      # callback err, json
      if json is null
        callback new Error("RankStream '#{time}' could not be found.")
      else
        rs = new RankStream JSON.parse(json)
        callback null, rs
        
  @last: (count, callback) ->
    RankStream.all (err, _rss) ->
      rss = _.last(_rss, count)
      callback null, rss
    
  # 1. filter by timestamp
  # 2. sort by timestamp
  # 3. get last (count) ranks streams
  @lastByTime: (count, interval, time, callback) ->
    RankStream.all (err, _rss) ->
      _rss = _.filter _rss, (rs) -> rs.timestamp > (time - interval)
      _rss = _.sortBy _rss, (rs) -> rs.timestamp
      rss  = _.last(_rss, count)
      callback null, rss
      
  # get all the rank streams
  @all: (callback) ->
    redis.hgetall RankStream.key(), (err, objects) ->
      rss = []
      for key, value of objects
        rs = new RankStream JSON.parse(value)
        rss.push rs
      callback null, rss  
  
  # table key name  
  @key: ->
    "RankStream:#{process.env.NODE_ENV}"
    
  # destroy all the data        
  @destroyAll: ->
    redis.del RankStream.key()

module.exports = RankStream