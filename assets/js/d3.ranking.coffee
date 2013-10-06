#= require d3.chart.line
#= require d3.rank.label

_       = require 'underscore'
Ranking = require 'ranking'
  
g_ranking    = new Ranking

lineAttr  = {"dom":"#activity-line", "width": 800, "height": 400, "time_frame": 1000 * 60 * 5, "tip_dom": "#linetip"}
lineChart = new @app.LineChart lineAttr

labelAttr = {"dom":"#activity-box", "width": 250, "height": 400, "labelWidth": 120, "labelHeight":25, "duration":500}
labelRank = new @app.LabelRank labelAttr

pull_history = () ->
  r_time  = new Date()
  r_step  = 1000
  r_intv  = 1000 * 60 * 3
  $.get "/ranks?step=#{r_step}&timestamp=#{r_time.getTime()}&interval=#{r_intv}", (data) ->
    hashtags      = data['hashtag']
    lastHashtags  = hashtags[hashtags.length-1]
    
    labelRank.setData lastHashtags.ranks
    labelRank.redraw()
    
    r_tags    = []
    _.each hashtags, (d) ->
      g_ranking.addRankData d, (ranking) ->
        r_tags = ranking.tags   
         
    lineChart.bindData r_tags 
    lineChart.redrawAxis r_tags, r_time
    lineChart.redraw()
    
    pull_ranks()

pull_ranks = () ->
  r_time  = new Date()
  r_step  = 1000
  r_intv  = 1000
  $.get "/ranks?step=#{r_step}&timestamp=#{r_time.getTime()}&interval=#{r_intv}", (data) ->
    hashtags      = data['hashtag']
    lastHashtags  = hashtags[hashtags.length-1]
    
    labelRank.setData lastHashtags.ranks
    labelRank.redraw()
    
    r_tags    = []
    g_ranking.addRankData lastHashtags, (ranking) ->
      r_tags = ranking.tags    
      lineChart.bindData r_tags if ranking.dirty
      lineChart.redrawAxis r_tags, r_time
      lineChart.redraw()
    
  setTimeout pull_ranks, r_step
  
pull_history()