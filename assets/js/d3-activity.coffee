#= require jquery-1.9.1.min.js
#= require underscore-min.js
#= require d3.v3.min.js

############ ADD DATA  
tags         = []
time_window  = 1000 * 60 * 5
_timestamp   = null

addRanking = (time, ranking, callback) ->
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
    

addData = (data) ->
  _timestamp = new Date(data.timestamp)
  rankings   = data.rankings
  
  dirty = false
  
  _.each rankings, (ranking) ->
    addRanking _timestamp, ranking, (_dirty) ->
      dirty = dirty | _dirty
      
  if dirty
    bindData tags
  
  redraw tags
    

################  draw
margin = { top: 20, right: 100, bottom: 30, left: 50}
graph_h = 500
graph_w = 900
transtion_t  = 500
label_h      = 25
label_w      = 140
box_w        = 300
box_h        = 500

width  = graph_w - margin.left - margin.right
height = graph_h - margin.top  - margin.bottom

# color
color = d3.scale.category20()

# box-y
boxY = d3.scale.ordinal()

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

svgbox = d3.select("#activity-box").append("svg")
    .attr("width", box_w)
    .attr("height", box_h)
  .append("g")
    .attr("transform", "translate(" + 10 + "," + 10 + ")")

# need to recompute domain each time 
redrawAxis = () ->
  startTime = _timestamp.getTime() - time_window
  maxY = d3.max(tags, (c) ->
    d3.max c.values, (v) ->
      v.value )
  x.domain [startTime, _timestamp]
  y.domain [0, maxY + maxY*0.2 ]
  
redrawLabels = () ->
  # box label needs to reorder when ranks change
  sortedTags = _.sortBy tags, (tag) -> tag.values[tag.values.length-1].value
  names = _.map sortedTags, (tag) -> tag.name  
  boxY.domain(names).range([names.length-1..0])
    
bindData = (data) ->
  # set color only when there's a new tag
  color.domain d3.keys( _.map data, (tag) -> tag.name )
  
  tagV = svg.selectAll(".tag").data(data).enter().append("g").attr("class", "tag")
  tagV.attr("clip-path", "url(#clip)").append("path").attr("class", "line")
  tagV.append("text")
  
  rect = svgbox.selectAll(".label").data(data).enter().append("g").attr("class", "label")
  rect.append("rect").attr("width", label_w).attr("height", label_h)
  rect.append("text")
  
# redraw path 
redraw = () ->
  
  redrawLabels()
  redrawAxis()
  
  svgXAxis.call d3.svg.axis().scale(x).orient("bottom")
  svgYAxis.call d3.svg.axis().scale(y).orient("left")
  
  tagV = svg.selectAll(".tag")
  
  tagV.selectAll("path").transition().duration(transtion_t).attr("d", (d) ->
    line d.values
  ).style "stroke", (d) ->
    color d.name
    
  # tagV.selectAll("text").transition().duration(200).attr("transform", (d) ->
  #   value = d.values[d.values.length - 1]
  #   "translate(" + x(value.time) + "," + y(value.value) + ")"
  # ).attr("x", 3).attr("dy", ".35em")
  #   .style("fill", (d) -> color d.name)
  #   .text (d) -> d.name
  
  svgbox.selectAll(".label").transition().duration(transtion_t).attr("transform", (d) ->
    "translate(" + 0 + "," + boxY(d.name)*label_h + ")"
  )
  
  svgbox.selectAll("rect").transition().duration(transtion_t).style("fill", (d) -> color d.name)
  svgbox.selectAll("text").attr("x", 3).attr("y", 20).style("fill", (d) -> "black").text (d) -> d.name + " [" + d.values[d.values.length-1].value + "]"

$ ->
  # Home page
  if window.location.pathname is '/'
    refresh = ->
      window.location = '/'

    socket = io.connect("/")
    socket.on "rankings:post", (data) ->
      return unless data
      data = if typeof data is 'string' then JSON.parse(data) else data
      addData data

    setTimeout refresh, time_window * 60

    # DEBUG
    window.socket = socket