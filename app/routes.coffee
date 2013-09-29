# GET home page.
routes = (app) ->
  
  app.all "*", (req, res, next) ->
    res.header "Access-Control-Allow-Origin", "*"
    res.header "Access-Control-Allow-Headers", "X-Requested-With"
    next()
  
  app.get '/', (req, res) ->
    res.render 'index', { title: 'Tweet Trends' } 
    
  app.post '/rankings', (req, res) ->  
    if socketIO = app.settings.socketIO
      socketIO.sockets.emit "rankings:post", req.body
    res.send "OK"
    
module.exports = routes
