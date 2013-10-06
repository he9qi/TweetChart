redis     = require('redis').createClient()
_         = require 'underscore'
RankBase  = require './rank_base'

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
    
    # table key name  
    @key: ->
      "ds:tweets:top_tweets:#{process.env.NODE_ENV}"

    self = @
    @lastByTime: (timestamp, interval, step, callback) ->
      RankBase.lastByTime self, timestamp, interval, step, callback

  module.exports = RankTweet