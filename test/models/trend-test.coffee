require '../_helper'
assert   = require 'assert'
redis    = require('redis').createClient()
Trend    = require '../../app/models/trend'

describe 'Trend', ->
  
  trendJson = { "name" : "word lenka", "values" : [{ "time":2000, "value":123 }] }
  
  describe "create", ->
    trend = null
    before (done) ->
      trend = new Trend trendJson
      done()
    it "doesn't id", ->
      assert.equal trend.id, null
    it "sets name", ->
      assert.equal trend.name, 'word lenka'
    it "sets values", ->
      assert.equal trend.values.length, 1
      assert.equal trend.values[0].time, 2000
      assert.equal trend.values[0].value, 123
    
    
  describe 'persistence', ->
    
    trend = null
      
    afterEach ->
      redis.del Trend.key()
  
    it "builds a key", ->
      assert.equal Trend.key(), 'Trend:test'
      
    describe "save", ->
      t = null
      before (done) ->
        trend = new Trend trendJson
        trend.save (err, _trend) ->
          t = _trend
          done()
      it "returns a Trend object", ->
        assert.instanceOf t, Trend
      it "sets id", ->
        assert.equal t.id, "word-lenka"
      
  describe "destroy", ->
    before (done) ->
      trend = new Trend trendJson
      trend.save ->
        done()

    it "destroys", (done)->
       Trend.getById 'word-lenka', (err, trend) ->
          trend.destroy (err) ->
            Trend.getById 'word-lenka', (err) ->
              assert.equal err.message, "Trend 'word-lenka' could not be found."
              done()
  
  describe 'add data', ->
    
    after ->
      redis.del Trend.key()
      
    before (done) ->
      Trend.addData data1, () ->
        done()
      
    data1  = {"rankings":[["#ICEWEASELS",167],["#ACE K",146]],"timestamp":1380206300509}
    data2  = {"rankings":[["#ICEWEASELS",169],["#BSE",149]],"timestamp":1380206300509}
    
    describe 'once', ->
        
      it "sets data for the names", (done) ->  
        Trend.all (err, _trends) ->
          trends = _trends
          done()
          assert.equal trends.length, 2
          trend = new Trend trends[0]
          assert.equal trend.id, "#ACE-K"
          
    describe 'twice', ->
      
      before (done) ->
        Trend.addData data2
        done()
        
      describe "all all data for the names", ->        
        it "sets length", (done) ->
          Trend.all (err, _trends) ->
            trends = _trends
            done()
            assert.equal trends.length, 3
      
      describe "multiple data for each name", ->      
        it "set name and values", (done) ->
          Trend.getById "#ICEWEASELS", (err, _trend) ->
            trend = _trend
            done()
            assert.equal trend.name, "#ICEWEASELS"  
            assert.equal trend.values.length, 2
          
