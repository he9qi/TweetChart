_     =  require('underscore')

#= require d3.rank.label

class TweetsRank extends @app.LabelRank
  
  constructor: (attr) ->
    super attr

  setDataAndSource: (data, source) ->  
    @source = source
    @setData data 
    @imageHeight = 48
    
  textInterpolate: (d) ->
    last = @__lastData or 0
    i = d3.interpolateRound(last, d.count)
    (t) ->
      @textContent = i(t)
  
  textStoreLastCount: (d) ->
    @__lastData = d.count
    
  buildLabel: (label)-> 
    # label.append("rect").attr("width", @labelWidth).attr("height", @labelHeight).attr("class", "label-box")
    # label.append("text").attr("class", "tweet-text")
    label.append("text").attr("class", "tweet-number text-number")
    label.append("image").attr("class", "tweet-user-icon")
    label.append('foreignObject').attr("class", "tweet-text-box")
                          .attr('x', 90)
                          .attr('height', @labelHeight)
                          .append("xhtml:body").data(@data)
                          .html (d) => '<div class="tweet-text"><textarea disabled readonly style="width: 287px; height: 85px; padding-top: 0px;">' + d.content + '</textarea></div>'
    
  redrawLabel: -> 
    # @svg.selectAll("rect").style("fill", "white")
      # .transition().duration(@duration).style("fill", (d) => @color d.name).attr("opacity", 0.05)
    
    @svg.selectAll(".tweet-text-box").data(@data).transition().duration(@duration).attr "y", (d) => @labelOffset(d.name)*@labelHeight
    
    @svg.selectAll("text.tweet-number").data(@data)
      .attr("x", 0).attr("y", 30)
      .style("fill", (d) -> "#006699").transition().tween("text", @textInterpolate).each("end", @textStoreLastCount)
    @svg.selectAll("image").data(@data)
      .attr("width", @labelHeight).attr("height", @imageHeight)
      .attr("x", 20).attr("y", 0)
      .attr "xlink:href", (d) => @source[d.id].user.profile_image_url
        
@app = window.app ? {}
@app.TweetsRank = TweetsRank