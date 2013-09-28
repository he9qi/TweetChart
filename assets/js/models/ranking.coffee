class Ranking
  constructor: () ->
    @tags = []
    
  addRanking: (time, ranking, tags, callback) ->
    name  = ranking[0]
    value = ranking[1]

    tag = _.find tags, (tag) ->
      name is tag.name

    if !!tag
      tag.values.push { time, value }
      callback false
    else
      values = []
      values.push { time, value }
      tags.push { "name":name, "values":values }
      callback true

  addData: (data, callback) ->
    timestamp = new Date(data.timestamp)
    rankings  = data.rankings

    dirty = false

    _.each rankings, (ranking) =>
      @addRanking timestamp, ranking, @tags, (_dirty) ->
        dirty = dirty | _dirty

    # remove data that is not included on current time
    names = _.map rankings, (ranking) -> ranking[0]
    @tags  = _.filter @tags, (d) -> d.name in names

    ranking = { "tags":@tags, "timestamp":timestamp, "dirty":dirty }
    callback(ranking)

@app = window.app ? {}
@app.Ranking = new Ranking