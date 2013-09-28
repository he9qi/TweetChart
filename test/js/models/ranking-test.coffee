require '../../_helper'
assert   = require 'assert'
Ranking  = require '../../../assets/js/models/ranking'

describe 'Ranking', ->
  
  # { 
  #   "rankings"  : [ ["#word1", 13], ["word2", 14] ], 
  #   "timestamp" : 424255223 
  # }
  rankingJson = { "timestamp" : 2000, "rankings" : [ ["#word1", 13], ["word2", 14] ] }
  
  describe "create", ->
    ranking = new Ranking
    
    ranking.addData rankingJson, (ranking) ->
      console.log "hello"
    
    it "sets rankings", ->
      assert.equal ranking.tags.length, 2
      
    
    

