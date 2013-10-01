_       = require 'underscore'
Ranking = require 'ranking'
  
g_ranking    = new Ranking

# constants
g_interval   = 1000 * 60 * 5
margin       = { top: 20, right: 80, bottom: 30, left: 50}
graph_h      = 460
graph_w      = 880
transtion_t  = 200
label_h      = 25
label_w      = 140
box_w        = 300
box_h        = 500
tip_offset   = { x: 0, y: 50 }

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
    .attr("width", width + margin.right)
    .attr("height", height + margin.top)

# draw axis first
svgXAxis = svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")")
svgXAxis.call d3.svg.axis().scale(x).orient("bottom")
svgYAxis = svg.append("g").attr("class", "y axis")
svgYAxis.call(d3.svg.axis().scale(y).orient("left")).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style "text-anchor", "end"

# activity box
svgbox = d3.select("#activity-box").append("svg")
    .attr("width", box_w)
    .attr("height", box_h)
  .append("g")
    # .attr("transform", "translate(" + 0 + "," + 0 + ")")


# need to recompute domain of x and y axis each time 
redrawAxis = (data, time) ->
  startTime = time.getTime() - g_interval
  maxY = d3.max(data, (c) ->
    d3.max c.values, (v) ->
      v.value )
  x.domain [startTime, time]
  y.domain [0, maxY + maxY*0.2 ]


# need to recomputer label position based on the ranking
redrawLabels = (data) ->
  # box label needs to reorder when ranks change
  sortedData = _.sortBy data, (d) -> d.values[d.values.length-1].value
  names = _.map sortedData, (d) -> d.name  
  boxY.domain(names).range([names.length-1..0])
    
    
# bind data whenever there's new data comes in
bindData = (data) ->
  
  # set color only when there's a new tag
  color.domain d3.keys( _.map data, (d) -> d.name )
  
  # 1. bind all data
  # 2. add new data
  # 3. remove old data
  tagData = svg.selectAll(".tag").data(data, (d) -> d.name)
  tagData.enter().append("g").attr("class", "tag").attr("clip-path", "url(#clip)").append("path").attr("class", "line")
    .attr("title", (d) -> d.name)
  tagData.exit().remove()
  
  # show tips for the data tags
  tagData.on "mouseover", ->
    data = @__data__
    mouse_x = d3.mouse(this)[0]
    mouse_y = d3.mouse(this)[1]
    $("#linetip").attr(style: "display: block; background: " + color(data.name) + "; top: " + (mouse_y + tip_offset.y) + "px; left: " + (mouse_x) + "px;").text(data.name)

  tagData.on "mouseout", ->
    data = @__data__
    mouse_x = d3.mouse(this)[0]
    mouse_y = d3.mouse(this)[1]
    $("#linetip").attr style: "display: none; top: " + (mouse_y + tip_offset.y) + "px; left: " + mouse_x + "px;"
  
  labelData = svgbox.selectAll(".label").data(data, (d) -> d.name)
  labelEnter = labelData.enter().append("g").attr("class", "label")
  labelEnter.append("rect").attr("width", label_w).attr("height", label_h).attr("class", "legend-box")
  labelEnter.append("text")
  labelData.exit().remove()
  
# redraw line graph and labels 
# each time frame, the following 3 things moves:
# 1. axis
# 2. lines
# 3. labels position and the count text
redraw = () ->
  
  # set new axis domain
  svgXAxis.call d3.svg.axis().scale(x).orient("bottom")
  svgYAxis.call d3.svg.axis().scale(y).orient("left")
  
  # move lines
  svg.selectAll(".tag").selectAll("path").transition().duration(transtion_t).attr("d", (d) ->
    line d.values
  ).style("stroke", (d) ->
    color d.name
  )
    
  # move labels and set new count on text
  svgbox.selectAll(".label").transition().duration(transtion_t).attr "transform", (d) ->
    "translate(" + 0 + "," + boxY(d.name)*label_h + ")"
  svgbox.selectAll("rect").transition().duration(transtion_t).style("fill", (d) -> color d.name)  
  svgbox.selectAll("text").attr("x", 3).attr("y", 20).style("fill", (d) -> "black").text (d) -> 
      d.name + " [" + d.values[d.values.length-1].value + "]"

addData = (data) ->
  

$ ->
  
  # Home page
  if window.location.pathname is '/rankings'
    refresh = ->
      window.location = '/rankings'
    
    socket = io.connect("/")
      
    r_count = 100
    r_time  = new Date()
    r_intv  = 300 # in seconds
    
    $.get "/rankstreams?count=#{r_count}&timestamp=#{r_time.getTime()}&interval=#{r_intv}", (data) ->
      r_tags = []
      _.each data, (d) ->
        g_ranking.addData d, (ranking) ->
          r_tags = ranking.tags
      
      if r_tags.length > 0
        bindData r_tags
        redrawLabels r_tags
        redrawAxis r_tags, r_time
        redraw()
            
      socket.on "rankings:post", (data) ->
        return unless data
        data = if typeof data is 'string' then JSON.parse(data) else data
          
        g_ranking.addData data, (ranking) ->
          bindData ranking.tags if ranking.dirty
          redrawLabels ranking.tags
          redrawAxis ranking.tags, ranking.timestamp
          redraw()
        
    setTimeout refresh, g_interval * 60

    # DEBUG
    window.socket = socket