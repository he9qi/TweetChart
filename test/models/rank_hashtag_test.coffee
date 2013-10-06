require '../_helper'
assert   = require 'assert'
redis    = require('redis').createClient()
RankHashtag  = require '../../app/models/rank_hashtag'

# "ds:tweets:rc_hashtags"
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

describe 'Rank Hashtags', ->
  
  data1 = { "category" : "stock/finacial", "ranks" : [ {"name":"chengdu", "count":1},     {"name":"los angeles", "count":2} ] }
  data2 = { "category" : "stock/finacial", "ranks" : [ {"name":"los angeles", "count":4}, {"name":"chengdu", "count":3} ] }
  data3 = { "category" : "stock/finacial", "ranks" : [ {"name":"beijing", "count":2},     {"name":"beijing", "count":6} ] }

  it "builds a key", ->
    assert.equal RankHashtag.key(), 'ds:tweets:rc_hashtags:test'
    
  describe "assign new", ->
    rankHashtag = null
    before (done) ->
      data1['timestamp'] = 1380781500000
      rankHashtag = new RankHashtag data1
      done()
    it "sets ranks", ->
      assert.equal rankHashtag.ranks.length, 2
      assert.equal rankHashtag.ranks[0].name, "chengdu"
      assert.equal rankHashtag.ranks[0].count, 1
    it "sets category", ->
      assert.equal rankHashtag.category, "stock/finacial"
    it "sets timestamp", ->
      assert.equal rankHashtag.timestamp, 1380781500000
    
  describe "get rank hashtag", ->
    
    before (done) ->
      redis.hmset RankHashtag.key(), 1380781500000, JSON.stringify(data1), 1380781501000, JSON.stringify(data2), 1380781502000, JSON.stringify(data3)
      done()
      
    after ->
      redis.del RankHashtag.key()
    
    rankUser = null
    
    it "get each second for last 2 seconds", (done) ->
      RankHashtag.lastByTime 1380781502000, 2000, 1000, (err, _rls) ->
        rls = _rls
        assert.equal rls.length, 2
        assert.equal rls[0].timestamp, 1380781501000
        assert.equal rls[1].timestamp, 1380781502000
        done()