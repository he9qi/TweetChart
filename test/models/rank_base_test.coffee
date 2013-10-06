require '../_helper'
assert   = require 'assert'
redis    = require('redis').createClient()
RankBase  = require '../../app/models/rank_base'
RankUser  = require '../../app/models/rank_user'
RankTweet  = require '../../app/models/rank_tweet'
RankLocation  = require '../../app/models/rank_location'
RankHashtag   = require '../../app/models/rank_hashtag'

describe 'Rank Base', ->
  
  data1 = { "category" : "stock/finacial", "ranks" : [ {"id":"u123", "name":"abc", "count":1}, {"id":"u256", "name":"cde", "count":2} ] }
  data2 = { "category" : "stock/finacial", "ranks" : [ {"id":"u256", "name":"cde", "count":4}, {"id":"u789", "name":"jkl", "count":3} ] }
  data3 = { "category" : "stock/finacial", "ranks" : [ {"id":"u789", "name":"jkl", "count":2}, {"id":"u123", "name":"abc", "count":6} ] }
  ldata1 = { "category" : "stock/finacial", "ranks" : [ {"name":"chengdu", "count":1},     {"name":"los angeles", "count":2} ] }
  ldata2 = { "category" : "stock/finacial", "ranks" : [ {"name":"los angeles", "count":4}, {"name":"chengdu", "count":3} ] }
  ldata3 = { "category" : "stock/finacial", "ranks" : [ {"name":"beijing", "count":2},     {"name":"beijing", "count":6} ] }
  tdata1 = { "category" : "stock/finacial", "ranks" : 
    [ {"id":"abc","content":"JavaScript that provides a lot of ...", "count":1},  {"id":"jkl","content":"Collection functions work on arrays, objects, and array-like objects", "count":3} ] }
  tdata2 = { "category" : "stock/finacial", "ranks" : 
    [ {"id":"cde","content":"Underscore is an open-source component", "count":2}, {"id":"abc","content":"JavaScript that provides a lot of ...", "count":1} ] }
  tdata3 = { "category" : "stock/finacial", "ranks" : 
    [ {"id":"abc","content":"JavaScript that provides a lot of ...", "count":5},  {"id":"cde","content":"Underscore is an open-source component", "count":7} ] }
  hdata1 = { "category" : "stock/finacial", "ranks" : [ {"name":"chengdu", "count":1},     {"name":"los angeles", "count":2} ] }
  hdata2 = { "category" : "stock/finacial", "ranks" : [ {"name":"los angeles", "count":4}, {"name":"chengdu", "count":3} ] }
  hdata3 = { "category" : "stock/finacial", "ranks" : [ {"name":"beijing", "count":2},     {"name":"beijing", "count":6} ] }
  describe "get rank base items", ->
    
    before (done) ->
      redis.hmset RankUser.key(), 1380781500000, JSON.stringify(data1), 1380781501000, JSON.stringify(data2), 1380781502000, JSON.stringify(data3)
      redis.hmset RankHashtag.key(), 1380781500000, JSON.stringify(hdata1), 1380781501000, JSON.stringify(hdata2), 1380781502000, JSON.stringify(hdata3)
      redis.hmset RankLocation.key(), 1380781500000, JSON.stringify(ldata1), 1380781501000, JSON.stringify(ldata2), 1380781502000, JSON.stringify(ldata3)
      redis.hmset RankTweet.key(), 1380781500000, JSON.stringify(tdata1), 1380781501000, JSON.stringify(tdata2), 1380781502000, JSON.stringify(tdata3)
      done()
      
    after ->
      redis.del RankUser.key()
      redis.del RankHashtag.key()
      redis.del RankLocation.key()
      redis.del RankTweet.key()
    
    rankUser = null
    
    it "get each second for last 2 seconds", (done) ->
      RankBase.lastByTime RankUser, 1380781502000, 2000, 1000, (err, _rus) ->
        rus = _rus
        assert.equal rus.length, 2
        assert.equal rus[0].timestamp, 1380781501000
        assert.equal rus[1].timestamp, 1380781502000
        done()
        
    it "get all ranks of class Users, Hashtags, Tweets and Locations for last 2 seconds", (done) ->
      RankBase.lastAllByTime [RankUser, RankHashtag, RankTweet, RankLocation], 1380781502000, 2000, 1000, (err, _data) ->
        data = _data        
        
        userJson     = data['user']
        locationJson = data['location']
        tweetJson    = data['tweet']
        hashtagJson  = data['hashtag']
        
        assert.equal userJson.length, 2
        assert.equal userJson[0]['ranks'].length, 2   
        assert.equal locationJson[0]['ranks'].length, 2
        assert.equal tweetJson[0]['ranks'].length, 2
        assert.equal hashtagJson[0]['ranks'].length, 2
        
        done()
        