_     =  require('underscore')

class BarChart
  
  constructor: (attr) ->
    @svg       = d3.select(attr.dom).append("svg")
                  .attr("width", attr.width)
                  .attr("height", attr.height)
                .append("g")
                
    @line      = @svg.append("line")
                
    @duration  = attr.duration || 500
    @barWidth  = attr.barWidth
    @barHeight = attr.barHeight
    @barOffset = { "x": attr.barWidth * 0.2, "y": attr.barHeight * 0.2 }

    @color     = d3.scale.category20()
    
    @x = d3.scale.linear().domain([0, 1]).range([0, @barWidth])
    @y = d3.scale.linear().rangeRound([0, @barHeight])
    
    @setData attr.data unless attr.data is undefined  
    
  calYDomain: ->
    maxY = d3.max @data, (d) -> d.count
    @y.domain [0, maxY + maxY*0.2 ]
  
  calBarY: (d) ->
    @barHeight - @y(d.count) - .5

  setData: (data) ->
    _groups   = @groups 
    @data     =  data
    @groups   = _.map @data, (d) -> d.name
    
    @line.attr("x1", 0)
      .attr("x2", (@barWidth + @barOffset.x) * @data.length)
      .attr("y1", @barHeight)
      .attr("y2", @barHeight)
      .style("stroke", "#000")
    
  redraw: ->
    that = @
    
    @calYDomain()
    
    @rect  = @svg.selectAll("rect").data(@data)
    
    # incoming rect
    @rect.enter().append("rect")
        .attr("x", (d, i) -> that.x(i) + that.barOffset.x * i )
        .attr("width", @barWidth)
      .transition().duration(@duration)    
        .attr("y", (d) -> that.calBarY(d) )
        .attr("height", (d) -> that.y(d.count) )
        .style("fill", (d) => @color d.name)
    
    # existing rect
    @rect.transition().duration(@duration)        
        .attr("y", (d) -> that.calBarY(d) )
        .attr("height", (d) -> that.y(d.count) )
        .style("fill", (d) => @color d.name)
        
    # exiting rect
    @rect.exit().transition().duration(@duration)   
        .attr("y", (d) -> 0 )
        .attr("height", (d) -> 0 )
        .remove()
        
    @text = @svg.selectAll("text.value").data(@data)
    @text.enter().append("text")
        .text( (d) -> d.count  )
        .attr("class", "value")
        .attr("x", (d, i) -> that.x(i) + that.barOffset.x * i )
      .transition().duration(@duration)    
        .attr("y", (d) -> that.calBarY(d) )
        .style("fill", (d) => @color d.name)
        
    @text.transition().duration(@duration)        
        .attr("y", (d) -> that.calBarY(d) )
        .attr("height", (d) -> that.y(d.count) )
        .style("fill", (d) => @color d.name)

    # exiting rect
    @text.exit().transition().duration(@duration)   
        .attr("y", (d) -> 0 )
        .attr("height", (d) -> 0 )
        .remove()
        
    @name = @svg.selectAll("text.name").data(@data)
    @name.enter().append("text")
        .text( (d) -> d.name  )
        .attr("class", "name")
        .attr("x", (d, i) -> that.x(i) + that.barOffset.x * i )
      .transition().duration(@duration)    
        .attr("y", (d) -> that.barHeight + that.barOffset.y )
        .style("fill", (d) => @color d.name)
        
    @name.transition().duration(@duration)     
        .style("fill", (d) => @color d.name)

    # exiting rect
    @name.exit().transition().duration(@duration)   
        .attr("y", (d) -> -10 ).remove()
        
@app = window.app ? {}
@app.BarChart = BarChart