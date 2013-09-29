
module.exports = (app, server) ->
  socketIO = require('socket.io').listen(server)
  unless app.settings.socketIO
    app.set 'socketIO', socketIO
  socketIO.sockets.on 'connection', (socket) ->
    console.log 'CONNECTED'