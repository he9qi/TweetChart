#= require d3.chart.line
#= require d3.rank.label

_       = require 'underscore'
Ranking = require 'ranking'
  
g_ranking    = new Ranking

lineAttr  = {"dom":"#activity-line", "width": 800, "height": 400, "time_frame": 1000 * 60 * 5, "tip_dom": "#linetip"}
lineChart = new @app.LineChart lineAttr

labelAttr = {"dom":"#activity-box", "width": 250, "height": 400, "labelWidth": 120, "labelHeight":25, "duration":500}
labelRank = new @app.LabelRank labelAttr

display = (time, intv, step, callback) ->
  
  $.get "/ranks?step=#{step}&timestamp=#{Math.round(time.getTime()/1000)}&interval=#{intv}", (data) ->
    hashtags      = data['hashtag']
    lastHashtags  = hashtags[hashtags.length-1]
    
    labelRank.setData lastHashtags.ranks
    labelRank.redraw()
    
    r_tags    = []
    _.each hashtags, (d) ->
      g_ranking.addRankData d, (ranking) ->
        r_tags = ranking.tags   
         
    lineChart.bindData r_tags 
    lineChart.redrawAxis r_tags, time
    lineChart.redraw()
  
    callback() unless callback is undefined

pull_history = () ->
  display new Date(), 60 * 3, 1, ->
    pull_ranks()

pull_ranks = () ->
  display new Date(), 1, 1
  setTimeout pull_ranks, 1000
  
pull_history()