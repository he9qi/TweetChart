class NumberText
  
  constructor: (attr) ->
    @width = attr.width
    @height = attr.height
    @svg = d3.select(attr.dom).append("svg")
            .attr("width", attr.width)
            .attr("height", attr.height)
            .attr("class", "svg-number")
          .append("g")
            .attr("width", attr.width)
            .attr("height", attr.height)
            
          
  setData: (_data) ->
    @data = [_data]
    textNumber = @svg.selectAll("text.text-number").data(@data)
    textNumber.enter().append("text")
      .attr("class", "exposure-number text-number")
      .attr("x", 0).attr("y", @height-10)
    textNumber.exit().remove()
          
  textInterpolate: (d) ->
    last = @__lastData or 0
    i = d3.interpolateRound(last, d.value)
    (t) ->
      @textContent = i(t)

  textStoreLastCount: (d) ->
    @__lastData = d.value      
    
  redraw: ->
    @svg.selectAll("text.text-number").data(@data)
      .style("fill", (d) -> "#006699").transition().tween("text", @textInterpolate).each("end", @textStoreLastCount)    

@app = window.app ? {}
@app.NumberText = NumberText