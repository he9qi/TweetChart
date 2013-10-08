_     =  require('underscore')

class LabelRank
  
  constructor: (attr) ->
    @dom         = attr.dom
    @duration    = attr.duration
    @labelWidth  = attr.labelWidth
    @labelHeight = attr.labelHeight
    @svg         = d3.select(attr.dom).append("svg")
                .attr("width", attr.width)
                .attr("height", attr.height)
              .append("g")
                # .attr("transform", "translate(" + attr.width / 2 + "," + attr.height / 2 + ")")
    
    @color        = d3.scale.category20()
    @labelOffset  = d3.scale.ordinal()
    
    @setData attr.data unless attr.data is undefined  

  setData: (data) ->
    
    _ids  = @ids
    @data = data
    
    @ids  = _.map @data, (d) -> 
      d['name'] = d.id if d.name is undefined
      d.name
    
    # bind if there's data change
    if _ids is undefined || _ids.length != @ids.length || (_.difference _ids, @ids).length > 0
      @bindData()
    
  bindData: ->
    # set color only when there's a new tag
    @color.domain d3.keys(@ids)
    
    labelData = @svg.selectAll(".label").data(@data)
    labelEnter = labelData.enter().append("g").attr("class", "label")
    @buildLabel labelEnter
    labelData.exit().remove()
    
    d3.select(@dom).selectAll("svg").attr("height", @data.length * @labelHeight + 15)
    
  buildLabel: (label) ->  
    label.append("rect").attr("width", @labelWidth).attr("height", @labelHeight).attr("class", "label-box")
    label.append("text")
    
  redrawLabel: ->
    @svg.selectAll("rect").transition().duration(@duration).style("fill", (d) => @color d.name)
    @svg.selectAll("text").data(@data).attr("x", 3).attr("y", 20).style("fill", (d) -> "black").text (d) ->
      d.name + " [" + d.count + "]"
    
  redraw: ->
    sorted = _.sortBy @data, (d) -> d.count
    @ids   = _.map sorted, (d) -> d.name  
    
    @labelOffset.domain(@ids).range([@ids.length-1..0])
    
    # move labels and set new count on text
    @svg.selectAll(".label").transition().duration(@duration).attr "transform", (d) =>
      "translate(" + 0 + "," + @labelOffset(d.name)*@labelHeight + ")"
    @redrawLabel()    
        
@app = window.app ? {}
@app.LabelRank = LabelRank