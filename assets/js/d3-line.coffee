#= require jquery-1.9.1.min.js
#= require underscore-min.js
#= require d3.v3.min.js

############ ADD DATA  
tags         = []
tagV         = null
time_window  = 1000 * 60 * 5

addRanking = (time, ranking) ->
  name  = ranking[0]
  value = ranking[1]

  tag = _.find tags, (tag) ->
    name is tag.name

  if !!tag
    tag.values.push { time, value }
    # console.log tag.values
  else
    values = []
    values.push { time, value }
    tags.push { "name":name, "values":values}
  
    names = _.map tags, (tag) -> tag.name  
    color.domain d3.keys(names)
    
    drawPath()

addData = (data) ->
  time     = new Date(data.timestamp)
  rankings = data.rankings
  _.each rankings, (ranking) ->
    addRanking time, ranking
  redraw()
    

################  draw
margin = { top: 20, right: 100, bottom: 30, left: 50}
width  = 1000 - margin.left - margin.right
height = 500 - margin.top  - margin.bottom

# color
color = d3.scale.category10()

# how to draw the line
line = d3.svg.line().interpolate("basis").x((d) -> x d.time).y((d) -> y d.value )

# svg x,y 
x    = d3.time.scale().range([0, width])
y    = d3.scale.linear().range([height, 0])

# svg container
svg = d3.select("#activity-line").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

# since the entering data point is drawn off the right edge, you’ll need a clip path
svg.append("defs").append("clipPath")
    .attr("id", "clip")
  .append("rect")
    .attr("width", width + 100)
    .attr("height", height + 50)

# draw axis first
xAxis = d3.svg.axis().scale(x).orient("bottom")
yAxis = d3.svg.axis().scale(y).orient("left")
svgXAxis = svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")")
svgXAxis.call d3.svg.axis().scale(x).orient("bottom")
svgYAxis = svg.append("g").attr("class", "y axis")
svgYAxis.call(d3.svg.axis().scale(y).orient("left")).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style "text-anchor", "end"

drawPath = () ->
  tagV = svg.selectAll(".tag").data(tags).enter().append("g").attr("class", "tag")
  tagV.attr("clip-path", "url(#clip)").append("path").attr("class", "line")
  tagV.append("text")

# need to recompute domain each time 
reDomain = () ->
  t1 = new Date().getTime()
  t0 = t1 - time_window

  x.domain [new Date(t0), new Date(t1)]
  y.domain [d3.min(tags, (c) ->
    d3.min c.values, (v) ->
      v.value
  ), d3.max(tags, (c) ->
    d3.max c.values, (v) ->
      v.value
  )]
  
# redraw path 
redraw = () ->
  reDomain()
  
  svgXAxis.call d3.svg.axis().scale(x).orient("bottom")
  svgYAxis.call d3.svg.axis().scale(y).orient("left")
  
  tagV = svg.selectAll(".tag").data(tags)
  
  tagV.selectAll("path").attr("d", (d) ->
    line d.values
  ).style "stroke", (d) ->
    color d.name
    
  tagV.selectAll("text").attr("transform", (d) ->
    value = d.values[d.values.length - 1]
    "translate(" + x(value.time) + "," + y(value.value) + ")"
  ).attr("x", 3).attr("dy", ".35em")
    .style("fill", (d) -> color d.name)
    .text (d) -> d.name

# chart redraw
updateChart = (data) ->  
  # console.log data
  if data
    data = if typeof data is 'string' then JSON.parse(data) else data
    addData data

$ ->
  # Home page
  if window.location.pathname is '/'
    refresh = ->
      window.location = '/'

    socket = io.connect("/")
    socket.on "rankings:post", (data) ->
      updateChart data

    setTimeout refresh, time_window * 60

    # DEBUG
    window.socket = socket