RankStream    = require __dirname + '/models/rank_stream'
RankBase      = require __dirname + '/models/rank_base'
RankUser      = require __dirname + '/models/rank_user'
RankTweet     = require __dirname + '/models/rank_tweet'
RankHashtag   = require __dirname + '/models/rank_hashtag'
RankExposure  = require __dirname + '/models/rank_exposure'
RankLocation  = require __dirname + '/models/rank_location'

mock          = require '../config/mock.coffee'
config        = require('../config/options.coffee').parse(process.argv)
client        = if config.mock then mock else RankBase

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
    
  app.post '/rankings', (req, res) ->  
    rs = new RankStream req.body
    rs.save (err, _rs) ->
    if socketIO = app.settings.socketIO
      socketIO.sockets.emit "rankings:post", req.body
    res.send "OK"
    
  app.get '/trends/:id', (req, res) ->
    res.render 'trends/show', { id : req.params.id }
    
  app.get '/ranks', (req, res) ->
    if req.query.step is undefined || req.query.interval is undefined || req.query.timestamp is undefined
      res.json([])
    else
      client.lastAllByTime [RankUser, RankHashtag, RankTweet, RankLocation, RankExposure], parseInt(req.query.timestamp), parseInt(req.query.interval), parseInt(req.query.step), (error, _data) ->
        res.json _data
    
module.exports = routes
