redis     = require('redis').createClient()
_         = require 'underscore'
RankBase  = require './rank_base'
Status    = require './status'

# "ds:tweets:top_tweets"
# 2013913131313 :
# {
#   "category" : "stock/finacial",
#   "timestamp" : 2013913131313,  // this is inserted when assign new
#   "ranks" : 
#   [
#     {"id":"abc", "content":"chengdu", "count":1},
#     {"id":"def", "content":"los angeles", "count":2},
#     {"id":"jkl", "content":"beijing", "count":3}
#   ]
# }
class RankTweet extends RankBase
  
  @modelClass: ->
    Status
    
  # table key name  
  @key: ->
    "ds:tweets:top_tweets"

  @lastByTime: (timestamp, interval, step, callback) =>
    RankBase.lastByTime @, timestamp, interval, step, callback

module.exports = RankTweet