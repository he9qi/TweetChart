require '../_helper'

fs       = require 'fs'
path     = require 'path'
assert   = require 'assert'
redis    = require('redis').createClient()
RankTweet= require '../../app/models/rank_tweet'
Status   = require '../../app/models/status'

# "ds:tweets:top_tweets"
#
# 1380781500000 :
# {
#   "category" : "stock/finacial",
#   "timestamp" : 1380781500000,  //this is inserted after assign new
#   "ranks" : 
#   [
#     {"id":"abc","content":"JavaScript that provides a lot of ...", "count":1},
#     {"id":"cde","content":"Underscore is an open-source component", "count":2},
#     {"id":"jkl","content":"Collection functions work on arrays, objects, and array-like objects", "count":3}
#   ]
# }

describe 'Rank Tweets', ->
  
  data1 = { "category" : "stock/finacial", "ranks" : 
    [ {"id":"abc","content":"JavaScript that provides a lot of ...", "count":1},  {"id":"jkl","content":"Collection functions work on arrays, objects, and array-like objects", "count":3} ] }
  data2 = { "category" : "stock/finacial", "ranks" : 
    [ {"id":174942523154894850,"content":"Underscore is an open-source component", "count":2}, {"id":"abc","content":"JavaScript that provides a lot of ...", "count":1} ] }
  data3 = { "category" : "stock/finacial", "ranks" : 
    [ {"id":"jkl","content":"JavaScript that provides a lot of ...", "count":5},  {"id":174942523154894850,"content":"Underscore is an open-source component", "count":7} ] }
    
  it "builds a key", ->
    assert.equal RankTweet.key(), 'ds:tweets:top_tweets'
    
  describe "assign new", ->
    rankTweet = null
    before (done) ->
      data1['timestamp'] = 1380781500000
      rankTweet = new RankTweet data1
      done()
    it "sets ranks", ->
      assert.equal rankTweet.ranks.length, 2
      assert.equal rankTweet.ranks[0].id, "abc"
      assert.equal rankTweet.ranks[0].content, "JavaScript that provides a lot of ..."
      assert.equal rankTweet.ranks[0].count, 1
    it "sets category", ->
      assert.equal rankTweet.category, "stock/finacial"
    it "sets timestamp", ->
      assert.equal rankTweet.timestamp, 1380781500000
    
  describe "get rank tweets", ->
    
    rls = null
    
    before (done) ->
      statusString = fs.readFileSync path.resolve(__dirname, '../sample/status.json'), { encoding: 'UTF-8', autoClose: true }
      statusJson = JSON.parse statusString
      redis.hset Status.key(), statusJson.id, JSON.stringify(statusJson)
      redis.hmset RankTweet.key(), 1380781500000, JSON.stringify(data1), 1380781501000, JSON.stringify(data2), 1380781502000, JSON.stringify(data3)
      RankTweet.lastByTime 1380781502000, 2000, 1000, (err, _rls) ->
        rls = _rls
        done()
      
    after ->
      redis.del RankTweet.key()
    
    it "sets rank tweets and timestamps", ->
      assert.equal rls.length, 2
      assert.equal rls[0].timestamp, 1380781501000
      assert.equal rls[1].timestamp, 1380781502000
    
    it "sets rank tweets ranks", ->
      assert.equal rls[0].ranks.length, 2
      
    it "doesn't set status info in the first item", ->
      assert.equal rls[0].models, null
      
    it "sets status info only in the last item", ->
      rankTweet = rls[1].models[174942523154894850]
      assert.equal rankTweet.id, 174942523154894851
      assert.equal rankTweet.created_at, 'Wed Feb 29 19:42:02 +0000 2012'
      assert.equal rankTweet.source, 'web'
      assert.equal rankTweet.retweet_count, 0
      