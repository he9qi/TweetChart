#= require d3.chart.pie
#= require d3.chart.bar
#= require d3.chart.line
#= require d3.rank.label

Ranking = require 'ranking'

pieAttr  = {"dom":"#activity-pie", "width": 400, "height": 350, "radius":150}
pieChart = new @app.PieChart pieAttr

labelAttr = {"dom":"body", "width": 150, "height": 350, "labelWidth": 150, "labelHeight":35, "duration":500}
labelRank = new @app.LabelRank labelAttr

barAttr = {"dom":"#exposure-chart", "width": 400, "height": 150, "barWidth": 36, "barHeight":120, "duration":500}
barChart = new @app.BarChart barAttr

g_ranking = new Ranking
lineAttr  = {"dom":"#activity-line", "width": 600, "height": 400, "time_frame": 1000 * 60 * 5, "tip_dom": "#linetip"}
lineChart = new @app.LineChart lineAttr

display = (time, intv, step, callback) ->
  
  $.get "/ranks?step=#{step}&timestamp=#{time.getTime()}&interval=#{intv}", (_data) ->
    
    userData = _data['user']
    userRanks = userData[userData.length-1].ranks
  
    r_tags    = []
    _.each userData, (d) ->
      g_ranking.addRankData d, (ranking) ->
        r_tags = ranking.tags   
       
    lineChart.bindData r_tags 
    lineChart.redrawAxis r_tags, time
    lineChart.redraw()
  
    pieChart.setData userRanks
    pieChart.redraw()
  
    barChart.setData userRanks
    barChart.redraw()
    
    callback() unless callback is undefined
  
pull_history = () ->
  display new Date(), 1000 * 60 * 3, 1000, ->
    pull_ranks()

pull_ranks = () ->
  display(new Date(), 1000, 1000)
  setTimeout pull_ranks, 3000
  
pull_history()