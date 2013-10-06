require '../_helper'
assert   = require 'assert'
redis    = require('redis').createClient()
RankUser  = require '../../app/models/rank_user'

# "ds:tweets:rank:users"
#
# 2013913131313 :
# {
#   "category" : "stock/finacial",
#   "timestamp" : 2013913131313,
#   "ranks" : 
#   [
#     {"id":"u123", "name":"abc", "count":1},
#     {"id":"u256", "name":"cde", "count":2},
#     {"id":"u789", "name":"jkl", "count":3}
#   ]
# }

describe 'Rank User', ->
  
  data1 = { "category" : "stock/finacial", "ranks" : [ {"id":"u123", "name":"abc", "count":1}, {"id":"u256", "name":"cde", "count":2} ] }
  data2 = { "category" : "stock/finacial", "ranks" : [ {"id":"u256", "name":"cde", "count":4}, {"id":"u789", "name":"jkl", "count":3} ] }
  data3 = { "category" : "stock/finacial", "ranks" : [ {"id":"u789", "name":"jkl", "count":2}, {"id":"u123", "name":"abc", "count":6} ] }

  it "builds a key", ->
    assert.equal RankUser.key(), 'ds:tweets:rank:users:test'
    
  describe "assign new", ->
    rankUser = null
    before (done) ->
      data1['timestamp'] = 1380781500000
      rankUser = new RankUser data1
      done()
    it "sets ranks", ->
      assert.equal rankUser.ranks.length, 2
      assert.equal rankUser.ranks[0].id, "u123"
      assert.equal rankUser.ranks[0].name, "abc"
      assert.equal rankUser.ranks[0].count, 1
    it "sets category", ->
      assert.equal rankUser.category, "stock/finacial"
    it "sets timestamp", ->
      assert.equal rankUser.timestamp, 1380781500000
    
  describe "get rank users", ->
    
    before (done) ->
      redis.hmset RankUser.key(), 1380781500000, JSON.stringify(data1), 1380781501000, JSON.stringify(data2), 1380781502000, JSON.stringify(data3)
      done()
      
    after ->
      redis.del RankUser.key()
    
    rankUser = null
    
    it "get each second for last 2 seconds", (done) ->
      RankUser.lastByTime 1380781502000, 2000, 1000, (err, _rus) ->
        rus = _rus
        assert.equal rus.length, 2
        assert.equal rus[0].timestamp, 1380781501000
        assert.equal rus[1].timestamp, 1380781502000
        done()