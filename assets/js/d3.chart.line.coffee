_     =  require('underscore')

class LineChart
  
  constructor: (attr) ->
    @tip_dom    = attr.tip_dom
    @tip_offset = { x: 0, y: 0 }
    @margin     = { top: 20, right: 80, bottom: 30, left: 50}
    @time_frame = attr.time_frame
    @width   = attr.width
    @height  = attr.height
    @svg     = d3.select(attr.dom).append("svg")
                .attr("width", attr.width)
                .attr("height", attr.height)
              .append("g")
                .attr("transform", "translate(" + @margin.left + "," + (-@margin.bottom) + ")")
    
    @color   = d3.scale.category20()
    @axis_offset = { x: @width - @margin.left - @margin.right, y: @height - @margin.top - @margin.bottom}

    # how to draw the line
    @line = d3.svg.line().interpolate("basis").x((d) -> @x d.time).y((d) -> @y d.value )

    # svg x,y 
    @x    = d3.time.scale().range([0, @axis_offset.x])
    @y    = d3.scale.linear().range([@axis_offset.y, 0])

    # since the entering data point is drawn off the right edge, you’ll need a clip path
    @svg.append("defs").append("clipPath")
        .attr("id", "clip")
      .append("rect")
        .attr("width", @width + @margin.right)
        .attr("height", @height + @margin.top)

    # draw axis first
    @svgXAxis = @svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + @axis_offset.y + ")")
    @svgXAxis.call d3.svg.axis().scale(@x).orient("bottom")
    @svgYAxis = @svg.append("g").attr("class", "y axis")
    @svgYAxis.call(d3.svg.axis().scale(@y).orient("left")).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style "text-anchor", "end"
    
  # need to recompute domain of x and y axis each time 
  redrawAxis: (data, time) ->
    startTime = time.getTime() - @time_frame
    maxY = d3.max(data, (c) ->
      d3.max c.values, (v) ->
        v.value )
    @x.domain [startTime, time]
    @y.domain [0, maxY + maxY*0.2 ]
      
  # bind data whenever there's new data comes in
  bindData: (data) ->
    that = @

    # set color only when there's a new tag
    @color.domain d3.keys( _.map data, (d) -> d.name )

    # 1. bind all data
    # 2. add new data
    # 3. remove old data
    tagData = @svg.selectAll(".tag").data(data, (d) -> d.name)
    tagData.enter().append("g").attr("class", "tag").attr("clip-path", "url(#clip)").append("path").attr("class", "line")
      .attr("title", (d) -> d.name)
    tagData.exit().remove()

    # show tips for the data tags
    tagData.on "mouseover", ->
      data = @__data__
      mouse_x = d3.mouse(this)[0]
      mouse_y = d3.mouse(this)[1]
      $(that.tip_dom).attr(style: "display: block; background: " + that.color(data.name) + "; top: " + (mouse_y + that.tip_offset.y) + "px; left: " + (mouse_x) + "px;").text(data.name)

    tagData.on "mouseout", ->
      data = @__data__
      mouse_x = d3.mouse(this)[0]
      mouse_y = d3.mouse(this)[1]
      $(that.tip_dom).attr style: "display: none; top: " + (mouse_y + that.tip_offset.y) + "px; left: " + mouse_x + "px;"    
      
      
  # redraw line graph and labels 
  # each time frame, the following 3 things moves:
  # 1. axis
  # 2. lines
  # 3. labels position and the count text
  redraw: () ->
    that = @
    
    # set new axis domain
    @svgXAxis.call d3.svg.axis().scale(@x).orient("bottom")
    @svgYAxis.call d3.svg.axis().scale(@y).orient("left")

    # move lines
    @svg.selectAll(".tag").selectAll("path").transition().duration(500).attr("d", (d) ->
      that.line d.values
    ).style("stroke", (d) ->
      that.color d.name
    )
    
@app = window.app ? {}
@app.LineChart = LineChart