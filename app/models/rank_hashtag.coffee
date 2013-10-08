redis     = require('redis').createClient()
_         = require 'underscore'
RankBase  = require './rank_base'

# "ds:tweets:rc_hashtags"
# 2013913131313 :
# {
#   "category" : "stock/finacial",
#   "timestamp" : 2013913131313,  // this is inserted when assign new
#   "ranks" : 
#   [
#     {"name":"chengdu", "count":1},
#     {"name":"los angeles", "count":2},
#     {"name":"beijing", "count":3}
#   ]
# }
class RankHashtag extends RankBase

  # table key name  
  @key: ->
    "ds:tweets:rc_hashtags"

  @lastByTime: (timestamp, interval, step, callback) ->
    RankBase.lastByTime @, timestamp, interval, step, callback

module.exports = RankHashtag