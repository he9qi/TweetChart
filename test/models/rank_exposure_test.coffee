require '../_helper'
assert   = require 'assert'
redis    = require('redis').createClient()
RankExposure  = require '../../app/models/rank_exposure'

describe 'Rank Exposure', ->
  
  data1 = { "value" : 12345 }
  data2 = { "value" : 12346 }
  data3 = { "value" : 12347 }
  
  it "set the key", ->
    assert.equal RankExposure.key(), "ds:tweets:exposure"
  
  describe 'assign new', ->
    rankExposure = null
    before (done) ->
      data1['timestamp'] = 1380781500000
      rankExposure = new RankExposure data1
      done()
    it "sets exposure value", ->
      assert.equal rankExposure.value, 12345
    it "sets timestamp", ->
      assert.equal rankExposure.timestamp, 1380781500000
  
  describe "get rank exposures", ->

    before (done) ->
      redis.hmset RankExposure.key(), 1380781500000, JSON.stringify(data1), 1380781501000, JSON.stringify(data2), 1380781502000, JSON.stringify(data3)
      done()

    after ->
      redis.del RankExposure.key()

    rankExposure = null

    it "get each second for last 2 seconds", (done) ->
      RankExposure.lastByTime 1380781502000, 2000, 1000, (err, _rus) ->
        rus = _rus
        assert.equal rus.length, 2
        assert.equal rus[0].timestamp, 1380781501000
        assert.equal rus[1].timestamp, 1380781502000
        assert.equal rus[0].value, 12346
        done()