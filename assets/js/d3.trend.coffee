#= require d3.chart.pie
#= require d3.chart.bar
#= require d3.chart.line
#= require d3.rank.label
#= require d3.rank.tweets
#= require d3.rank.users
#= require d3.text.number

Ranking = require 'ranking'

pieAttr  = {"dom":"#locations-pie", "width": 250, "height": 250, "radius":80}
pieChart = new @app.PieChart pieAttr

tweetsRankAttr = {"dom":"#top-tweets-chart", "width": 387, "height": 800, "labelWidth": 387, "labelHeight":85, "duration":500}
tweetsRank = new @app.TweetsRank tweetsRankAttr

usersRankAttr = {"dom":"#top-users-chart", "width": 300, "height" : 800, "labelWidth": 300, "labelHeight": 85, "duration":500}
usersRank = new @app.UsersRank usersRankAttr

barAttr = {"dom":"#exposure-chart", "width": 500, "height": 150, "barWidth": 45, "barHeight":120, "duration":500}
barChart = new @app.BarChart barAttr

# g_ranking = new Ranking
# lineAttr  = {"dom":"#activity-line", "width": 600, "height": 400, "time_frame": 1000 * 60 * 5, "tip_dom": "#linetip"}
# lineChart = new @app.LineChart lineAttr
# 
# labelRankAttr = {"dom":"#activity-label", "width": 300, "height": 400, "labelWidth": 300, "labelHeight":30, "duration":500}
# labelRank = new @app.LabelRank labelRankAttr

exposureAttr = {"dom":"#exposure-text", "width":350, "height":110}
exposureText = new @app.NumberText exposureAttr

locationLabelRankAttr = {"dom":"#locations-label", "width": 250, "height": 220, "labelWidth": 250, "labelHeight":38, "duration":500}
locationLabelRank = new @app.LabelRank locationLabelRankAttr

display = (time, intv, step, callback) ->
  
  $.get "/ranks?step=#{step}&timestamp=#{time.getTime()}&interval=#{intv}", (_data) ->
    
    userData = _data['user']
    lastUserData = userData[userData.length-1]
    userRanks  = lastUserData.ranks
    userSource = lastUserData.models
    
    tweetData   = _data['tweet']
    lastTweetData = tweetData[tweetData.length-1]
    tweetRanks  = lastTweetData.ranks
    tweetSource = lastTweetData.models
    
    locationData = _data['location']
    lastLocationData = locationData[locationData.length-1]
    locationRanks  = lastLocationData.ranks
    locationSource = lastLocationData.models
    
    hashtagData = _data['hashtag']
    lastHashtagData = hashtagData[hashtagData.length-1]
    hashtagRanks  = lastHashtagData.ranks
    hashtagSource = lastHashtagData.models
    
    exposureData = _data['exposure']
    lastExposureData = exposureData[exposureData.length-1]
  
    # r_tags    = []
    # _.each userData, (d) ->
    #   g_ranking.addRankData d, (ranking) ->
    #     r_tags = ranking.tags   
    #    
    # lineChart.bindData r_tags 
    # lineChart.redrawAxis r_tags, time
    # lineChart.redraw()

    # labelRank.setData userRanks
    # labelRank.redraw()
  
    pieChart.setData locationRanks
    pieChart.redraw()
  
    barChart.setData hashtagRanks
    barChart.redraw()
  
    locationLabelRank.setData locationRanks
    locationLabelRank.redraw()
    
    tweetsRank.setDataAndSource tweetRanks, tweetSource
    tweetsRank.redraw()
    
    usersRank.setDataAndSource userRanks, userSource
    usersRank.redraw()
    
    exposureText.setData lastExposureData
    exposureText.redraw()
    
    callback() unless callback is undefined
  
pull_history = () ->
  display new Date(), 1000 * 60 * 3, 1000, ->
    pull_ranks()

pull_ranks = () ->
  display(new Date(), 1000, 1000)
  setTimeout pull_ranks, 3000
  
pull_history()