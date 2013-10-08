redis     = require('redis').createClient()
RankBase  = require './rank_base'

class RankExposure extends RankBase
  
  @key: ->
    "ds:tweets:exposure"

  @lastByTime: (timestamp, interval, step, callback) =>
    RankBase.lastByTime @, timestamp, interval, step, callback
  
module.exports = RankExposure