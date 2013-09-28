###
Module dependencies.
###

require "coffee-script"

express = require("express")
http = require("http")
path = require("path")

config  = require('./config/options.coffee').parse(process.argv)

app = express()
server = http.createServer(app)
require("./apps/socket-io") app, server

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# connect asssets - rails 3.0 like pipline
app.use require("connect-assets")()

# configurations
app.configure 'development', ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })
  
app.configure 'production', ->
  app.use express.errorHandler()

app.configure 'test', ->
  app.set 'port', 3001


# routes
require("./apps/routes") app

# server
server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
  
# mock data
mock_rankings_request = () ->
  mock.post_rankings app, (error, data) ->
    if error then return console.log error
    setTimeout mock_rankings_request, 2000  
  
if config.mock
  console.log "======== mock rankings mode =========\n"
  mock    = require './config/mock.coffee'
  mock_rankings_request()
