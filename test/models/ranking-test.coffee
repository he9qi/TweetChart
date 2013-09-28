require '../_helper'
assert   = require 'assert'
redis    = require('redis').createClient()
Ranking  = require '../../models/ranking'

describe 'Ranking', ->
  
  # { 
  #   "rankings"  : [ ["#word1", 13], ["word2", 14] ], 
  #   "timestamp" : 424255223 
  # }
  rankingJson = { "timestamp" : 2000, "rankings" : [ ["#word1", 13], ["word2", 14] ] }
  
  describe "create", ->
    ranking = null
    before (done) ->
      ranking = new Ranking rankingJson
      done()
    it "sets timestamp", ->
      assert.equal ranking.timestamp, 2000
    it "sets rankings", ->
      assert.equal ranking.rankings.length, 2
      assert.equal ranking.rankings[0][0], "#word1"
      assert.equal ranking.rankings[0][1], 13
      
    
    

