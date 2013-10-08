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
    RankBase.lastByTime @, timestamp, interval, step, callback#(err, rts, rank_name) ->
      
      # # get the ids
      # ids = []
      # for key, value of rts
      #   ids.push _.map value.ranks, (d) -> d.id
      # ids = _.uniq (_.flatten ids)
      # 
      # # put ids to models in the last item
      # Status.getByIds ids, (err, _statuses) ->
      #   rts[rts.length-1]['models'] = {}
      #   for i, _status of _statuses
      #     unless _status['id'] is undefined 
      #       rts[rts.length-1].models[_status.id] = _status
      #   callback err, rts, rank_name

module.exports = RankTweet