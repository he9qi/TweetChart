_     =  require('underscore')

#= require d3.rank.label

class UsersRank extends @app.LabelRank
  
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
    
  dataToHtml: (d) ->
    user = @source[d.id]
    return '<div class="row col-md-12 user-info-row">'\
    + '<div class="user-icon col-md-3"><img src="'  + user.profile_image_url + '" /></div>' \
    + '<div class="user-stats col-md-9">' \
    + '<p class="user-stats-name"><span class="col-md-12 user-number text-number">' + d.count + '</span>@' + user.name + '</p>' \
    + '<div class="user-stats-count statuses col-md-4"><span class="count-number">'  + user.statuses_count + '</span><br/><span class="count-text">statuses</span></div>' \
    + '<div class="user-stats-count followers col-md-4"><span class="count-number">' + user.followers_count + '</span><br/><span class="count-text">followers</span></div>' \
    + '<div class="user-stats-count following col-md-4"><span class="count-number">' + user.friends_count + '</span><br/><span class="count-text">following</span></div>' \
    + '</div></div>'
    
  buildLabel: (label)->   
    # label.append("text").attr("class", "user-number text-number")
    # label.append("image").attr("class", "user-icon")
    label.append('foreignObject').attr("class", "user-info-box")
                          .attr('x', 0)
                          .attr('height', @labelHeight)
                          .append("xhtml:body").data(@data)
                          .html @dataToHtml.bind(@)
    
  redrawLabel: -> 
    
    @svg.selectAll(".user-info-box").data(@data).transition().duration(@duration).attr( "y", (d) => @labelOffset(d.name)*@labelHeight)
    
    # @svg.selectAll("text.tweet-number").data(@data)
    #   .attr("x", 12).attr("y", @labelHeight/2)
    #   .style("fill", (d) -> "#006699").transition().tween("text", @textInterpolate).each("end", @textStoreLastCount)
    # @svg.selectAll("image").data(@data)
    #   .attr("width", @labelHeight).attr("height", @imageHeight)
    #   .attr("x", @imageHeight-3).attr("y", @labelHeight/2-@imageHeight/2)
    #   .attr "xlink:href", (d) => @source[d.id].user.profile_image_url
        
@app = window.app ? {}
@app.UsersRank = UsersRank