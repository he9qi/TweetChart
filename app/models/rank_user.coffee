redis     = require('redis').createClient()
_         = require 'underscore'
RankBase  = require './rank_base'
User      = require './user'

# "ds:tweets:rank:users"
# 2013913131313 :
# {
#   "category" : "stock/finacial",
#   "timestamp" : 2013913131313,  //this is insert when creating new rank user
#   "ranks" : 
#   [
#     {"id":"u123", "name":"abc", "count":1},
#     {"id":"u256", "name":"cde", "count":2},
#     {"id":"u789", "name":"jkl", "count":3}
#   ]
# }
class RankUser extends RankBase

  @modelClass: ->
    User

  # table key name  
  @key: ->
    "ds:tweets:top_users"

  @lastByTime: (timestamp, interval, step, callback) =>
    RankBase.lastByTime @, timestamp, interval, step, callback

module.exports = RankUser