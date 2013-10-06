_     =  require('underscore')

class PieChart
  
  constructor: (attr) ->
    @radius  = attr.radius
    @labelr  = attr.radius * 1.01
    @svg     = d3.select(attr.dom).append("svg")
                .attr("width", attr.width)
                .attr("height", attr.height)
              .append("g")
                .attr("transform", "translate(" + attr.width / 2 + "," + attr.height / 2 + ")")
    
    @color   = d3.scale.category20()
    @pie     = d3.layout.pie().sort(null)
    @arc     = d3.svg.arc().innerRadius(@radius * .5).outerRadius(@radius * .95);
    
    @setData attr.data unless attr.data is undefined  

  setData: (data) ->
    _groups   = @groups 
    @data     =  data
    @groups   = _.map @data, (d) -> d.name
    
    if _groups is undefined || _groups.length != @groups.length || (_.difference _groups, @groups).length > 0
      @bindData()
    
  typeToValue: (g) => 
    o = _.find @data, (d) -> d.name is g
    if o is undefined then 0 else o.count
  
  typeToObject: (g) =>
    _.find @data, (d) -> d.name is g
  
  bindData: ->
    that = @
    @path = @svg.selectAll("path").data(@groups)
    @path.enter().append("path").style("fill", @color).each ->
      @_current =
        startAngle: 0
        endAngle: 0
    @path.exit().remove()
    
    @label = @svg.selectAll(".label").data(@groups)
    @label.enter().append("g").attr("class", "label").append("text").style("fill", @color)
    @label.exit().remove()
    
  redraw: ->
    that = @
    pieData = @pie.value(@typeToValue)(@groups)
    
    @path.data(pieData).transition().attrTween "d", (a) ->
      i = d3.interpolate(@_current, a)
      @_current = i(0)
      (t) ->
        that.arc i(t)
    
    @label.data(pieData).attr("transform", (d) -> 
      c = that.arc.centroid(d)
      x = c[0]
      y = c[1]
      h = Math.sqrt(x * x + y * y)
      "translate(" + (x / h * that.labelr) + "," + (y / h * that.labelr) + ")" )
      .attr("dy", ".35em").attr( "text-anchor", (d) ->
            (if (d.endAngle + d.startAngle) / 2 > Math.PI then "end" else "start") )

    @svg.selectAll("text").data(@data).text (d, i) ->
      d.name + "[" + d.count + "]"
      
        
@app = window.app ? {}
@app.PieChart = PieChart