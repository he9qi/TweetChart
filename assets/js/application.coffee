# #= require jquery-1.9.1.min.js
# #= require underscore-min.js
# 
# jQuery ->
#   # Home page
#   if window.location.pathname is '/'
#     refresh = ->
#       window.location = '/'
# 
#     socket = io.connect("/")
#     socket.on "rankings:post", (msg) ->
#       console.log msg
# 
#     setTimeout refresh, 1000*60
# 
#     # DEBUG
#     window.socket = socket