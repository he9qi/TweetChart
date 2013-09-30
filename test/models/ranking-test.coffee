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
  
  describe "adds data", ->
    
    data    = null
    ranking = new Ranking   
    before () ->
      ranking.addData data1, (_data) ->
        data = _data
    
    describe "once", ->
        
      it "sets timestamp", ->
        assert.equal data.timestamp.getTime(), 2000  
      
      it "sets tags", ->
        assert.equal data.tags.length, 2
        assert.equal data.tags[0].name, "#word1"
      
    describe "twice", ->      

      before () ->
        ranking.addData data2, (_data) ->
          data = _data
      
      it "sets timestamp", ->
        assert.equal data.timestamp.getTime(), 2001

      it "sets tags", ->
        assert.equal data.tags.length, 2
        assert.equal data.tags[0].name, "#word2"
        assert.equal data.tags[0].values.length, 2
        assert.equal data.tags[1].name, "#word3"
    
    describe "adds too much", ->
      
      before () ->
        ranking = new Ranking 1
        ranking.addData data1, (_data) ->
          ranking.addData data2, (_data) ->
            data = _data
    
      it "sets the max tags count", ->
        assert.equal ranking.maxTagsCount, 1
   
      it "sets only the limited size of a tag", ->
        assert.equal data.tags.length, 2
        assert.equal data.tags[0].name, "#word2"
        assert.equal data.tags[0].values.length, 1
        assert.equal data.tags[0].values[0].time.getTime(), 2001 # coz only the last timestamp is saved

  describe "sort data", ->
    
    data = null
    ranking = null
    
    before () ->
      ranking = new Ranking
      ranking.addData data1, (_data) ->
        ranking.addData data2, (_data) ->
          data = _data
    
    it "set the length", ->
      assert.equal data.tags.length, 2
      
    it "set the tags", ->
      assert.equal data.tags[0].name, "#word2"
      assert.equal data.tags[0].values[0].time.getTime(), 2000
    