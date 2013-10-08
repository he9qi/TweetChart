require '../_helper'
assert   = require 'assert'
redis    = require('redis').createClient()
RankLocation  = require '../../app/models/rank_location'

# "ds:tweets:top_locations"
#
# 2013913131313 :
# {
#   "category" : "stock/finacial",
#   "timestamp" : 2013913131313,
#   "ranks" : 
#   [
#     {"name":"chengdu", "count":1},
#     {"name":"los angeles", "count":2},
#     {"name":"beijing", "count":3}
#   ]
# }

describe 'Rank Locations', ->
  
  data1 = { "category" : "stock/finacial", "ranks" : [ {"name":"chengdu", "count":1},     {"name":"los angeles", "count":2} ] }
  data2 = { "category" : "stock/finacial", "ranks" : [ {"name":"los angeles", "count":4}, {"name":"chengdu", "count":3} ] }
  data3 = { "category" : "stock/finacial", "ranks" : [ {"name":"beijing", "count":2},     {"name":"beijing", "count":6} ] }

  it "builds a key", ->
    assert.equal RankLocation.key(), 'ds:tweets:top_locations'
    
  describe "assign new", ->
    rankLocation = null
    before (done) ->
      data1['timestamp'] = 1380781500000
      rankLocation = new RankLocation data1
      done()
    it "sets ranks", ->
      assert.equal rankLocation.ranks.length, 2
      assert.equal rankLocation.ranks[0].name, "chengdu"
      assert.equal rankLocation.ranks[0].count, 1
    it "sets category", ->
      assert.equal rankLocation.category, "stock/finacial"
    it "sets timestamp", ->
      assert.equal rankLocation.timestamp, 1380781500000
    
  describe "get rank locations", ->
    
    before (done) ->
      redis.hmset RankLocation.key(), 1380781500000, JSON.stringify(data1), 1380781501000, JSON.stringify(data2), 1380781502000, JSON.stringify(data3)
      done()
      
    after ->
      redis.del RankLocation.key()
    
    rankUser = null
    
    it "get each second for last 2 seconds", (done) ->
      RankLocation.lastByTime 1380781502000, 2000, 1000, (err, _rls) ->
        rls = _rls
        assert.equal rls.length, 2
        assert.equal rls[0].timestamp, 1380781501000
        assert.equal rls[1].timestamp, 1380781502000
        done()