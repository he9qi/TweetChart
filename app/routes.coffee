RankStream  = require __dirname + '/models/rank_stream'

# GET home page.
routes = (app) ->
  
  app.all "*", (req, res, next) ->
    res.header "Access-Control-Allow-Origin", "*"
    res.header "Access-Control-Allow-Headers", "X-Requested-With"
    next()
  
  app.get '/', (req, res) ->
    res.render 'index', { title: 'Tweet Trends' } 
    
  app.get '/rankings', (req, res) ->
    res.render 'rankings/index', { title: "Tweets Ranking" }
    
  app.get '/rankstreams', (req, res) ->
    if req.query.count is undefined || req.query.interval is undefined || req.query.timestamp is undefined
      res.json([])
    else
      RankStream.lastByTime req.query.count, req.query.interval * 1000, req.query.timestamp, (err, _rss)->
        res.json(_rss)
    
  app.post '/rankings', (req, res) ->  
    rs = new RankStream req.body
    rs.save (err, _rs) ->
    if socketIO = app.settings.socketIO
      socketIO.sockets.emit "rankings:post", req.body
    res.send "OK"
    
module.exports = routes
