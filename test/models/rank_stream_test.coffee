require '../_helper'
assert   = require 'assert'
redis    = require('redis').createClient()
RankStream  = require '../../app/models/rank_stream'

describe 'Rank Stream', ->
  
  data1 = { "timestamp" : 2000, "rankings" : [ ["#word1", 13], ["#word2", 14] ] }
  data2 = { "timestamp" : 2001, "rankings" : [ ["#word3", 13], ["#word2", 15] ] }
  data3 = { "timestamp" : 2002, "rankings" : [ ["#word2", 11], ["#word3", 12] ] }

  it "builds a key", ->
    assert.equal RankStream.key(), 'RankStream'
  
  describe "create", ->
    
    rankStream = null
    
    before ->
      rankStream = new RankStream data1

    it "sets timestamp", ->
      assert.equal rankStream.timestamp, 2000

    it "sets rankings", ->
      assert.equal rankStream.rankings.length, 2
      assert.equal rankStream.rankings[0][0], "#word1"
      assert.equal rankStream.rankings[0][1], 13
  
  describe "persistence", ->
    
    rankStream = null
    
    afterEach ->
      redis.del RankStream.key()
            
    describe "save", ->
      before (done) ->
        rankStream = new RankStream data1
        rankStream.save ->
          done()
      it "returns a rank stream object", ->
        assert.instanceOf rankStream, RankStream   
      it "sets timestamp", ->
        assert.equal rankStream.timestamp, 2000
      it "get the rank stream", (done) ->
        RankStream.getByTime 2000, (err, rs) ->
          rankStream = rs
          done()
        assert.instanceOf rankStream, RankStream
        assert.equal rankStream.timestamp, 2000
        
    describe "destroy", ->
      before (done) ->
        rankStream = new RankStream data1
        rankStream.save ->
          done()
      
      it "destroys", (done)->
       RankStream.getByTime 2000, (err, rs) ->
          rs.destroy (err) ->
            RankStream.getByTime 2000, (err) ->
              assert.equal err.message, "RankStream '2000' could not be found."
              done()
    
  describe "get rank streams", ->
    
    rankStream = null
    
    before (done) ->
      rankStream = new RankStream data1
      rankStream.save ->
        rs = new RankStream data2
        rs.save ->
          rs1 = new RankStream data3
          rs1.save ->
            done()
        
    it "get all", (done) ->
      RankStream.all (err, _rss)->
        rss = _rss
        assert.equal rss.length, 3
        done()
           
    it "get last 2", (done) ->
      RankStream.last 2, (err, _rss)->
        rss = _rss
        assert.equal rss.length, 2
        done()
        
    it "get 2 ranks of last 5 mins", (done) ->
      RankStream.lastByTime 2, 300, 2003, (err, _rss) ->
        rss = _rss
        assert.equal rss.length, 2
        assert.equal rss[0].timestamp, 2001
        assert.equal rss[1].timestamp, 2002
        done()
          
    it "cannot get last 2 because time has passed", (done) ->
      RankStream.lastByTime 2, 300, 2000000, (err, _rss) ->
        rss = _rss
        assert.equal rss.length, 0
        done()
        