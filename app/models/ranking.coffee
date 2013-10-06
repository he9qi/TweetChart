_     = require 'underscore'

class Ranking
  constructor: (_maxTagsCount) ->
    @tags = []
    @maxTagsCount = if _maxTagsCount is undefined then 500 else _maxTagsCount
      
  addRank: (time, rank, tags, callback) ->
    name  = rank.name
    value = rank.count

    tag = _.find tags, (tag) ->
      name is tag.name

    if !!tag
      tag.values.push { time, value }
      tag.values.shift() if tag.values.length > @maxTagsCount
      callback false
    else
      values = []
      values.push { time, value }
      tags.push { "name":name, "values":values }
      callback true
      
  addRankData: (data, callback) ->
    timestamp = new Date(data.timestamp)
    ranks     = data.ranks
    
    dirty = false

    # sort before pushing
    _.each @tags, (t) ->
      t.values = _.sortBy t.values, (v) -> v.time.getTime()

    _.each ranks, (rank) =>
      @addRank timestamp, rank, @tags, (_dirty) ->
        dirty = dirty | _dirty

    # remove data whose name that is not included on current time
    names = _.map ranks, (rank) ->  rank.name
    @tags  = _.filter @tags, (d) -> d.name in names
    
    rank = { "tags":@tags, "timestamp":timestamp, "dirty":dirty }
    callback(rank)

module.exports = Ranking