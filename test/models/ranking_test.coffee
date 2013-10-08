require '../_helper'
assert   = require 'assert'
Ranking  = require '../../app/models/ranking'

describe 'Ranking', ->
  
  # { 
  #   "rankings"  : [ ["#word1", 13], ["word2", 14] ], 
  #   "timestamp" : 424255223 
  # }
  data1 = { "timestamp" : 2000, "rankings" : [ ["#word1", 13], ["#word2", 14] ] }
  data2 = { "timestamp" : 2001, "rankings" : [ ["#word3", 13], ["#word2", 15] ] }
  
  data3 = { "timestamp" : 2000,  "category" : "Stock", "ranks" : 
    [ {"id":"ur1", "name":"rooney12","count": 111 },
      {"id":"ur2", "name":"zorolen", "count": 123 },
      {"id":"ur3", "name":"beckham", "count": 131 } ] }
      
  data4 = { "timestamp" : 2001,  "category" : "Stock", "ranks" : 
    [ {"id":"ur1", "name":"rooney12","count": 191 },
      {"id":"ur2", "name":"zorolen", "count": 143 },
      {"id":"ur3", "name":"mjordan", "count": 152 } ] }    
      
  data5 = { "timestamp" : 2002,  "category" : "Stock", "ranks" : 
    [ {"id":"ur1", "name":"rooney12","count": 291 },
      {"id":"ur2", "name":"beckham", "count": 243 },
      {"id":"ur3", "name":"mjordan", "count": 252 } ] }  
      
  describe "adds data", ->
  
    data    = null
    ranking = new Ranking   
    before () ->
      ranking.addRankData data3, (_data) ->
        data = _data
  
    describe "once", ->
  
      it "sets timestamp", ->
        assert.equal data.timestamp.getTime(), 2000  
  
      it "sets tags", ->
        assert.equal data.tags.length, 3
        assert.equal data.tags[0].name, "rooney12"
  
    describe "twice", ->      
  
      before () ->
        ranking.addRankData data4, (_data) ->
          data = _data
  
      it "sets timestamp", ->
        assert.equal data.timestamp.getTime(), 2001
  
      it "sets tags", ->
        assert.equal data.tags.length, 3
        assert.equal data.tags[0].name, "rooney12"
        assert.equal data.tags[0].values.length, 2
        assert.equal data.tags[1].name, "zorolen"
  
    describe "adds too much", ->
  
      before () ->
        ranking = new Ranking 1
        ranking.addRankData data3, (_data) ->
          ranking.addRankData data4, (_data) ->
            data = _data
  
      it "sets the max tags count", ->
        assert.equal ranking.maxTagsCount, 1
  
      it "sets only the limited size of a tag", ->
        assert.equal data.tags.length, 3
        assert.equal data.tags[0].name, "rooney12"
        assert.equal data.tags[0].values.length, 1
        assert.equal data.tags[0].values[0].time.getTime(), 2001 # coz only the last timestamp is saved
  
  describe "sort data", ->
  
    data = null
    ranking = null
  
    before () ->
      ranking = new Ranking
      ranking.addRankData data4, (_data) ->
        ranking.addRankData data3, (_data) ->
          ranking.addRankData data5, (_data) ->
            data = _data
  
    it "set the length", ->
      assert.equal data.tags.length, 3
  
    it "set the tags", ->
      assert.equal data.tags[0].name, "rooney12"
      assert.equal data.tags[0].values[0].time.getTime(), 2000