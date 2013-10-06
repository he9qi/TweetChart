_ = require 'underscore'

semirandom = ( min, mod )-> Math.floor Math.random()*mod+min

occationalize = (data, randoms) ->
  onOccasion =  ( Math.floor( Math.random()*2 )%2 is 1 )
  if onOccasion
    randidx  = Math.floor Math.random()*randoms.length
    dataidx  = Math.floor Math.random()*data.length
    data[dataidx] = randoms[randidx]
  return data
  
hashtags = -> 
  return [
    {"name":"nba",       "count":semirandom(21, 67)},
    {"name":"stock",     "count":semirandom(31, 52)},
    {"name":"earthquake", "count":semirandom(13, 49)},
    {"name":"piechart",  "count":semirandom(32, 112)},
    {"name":"vocano",    "count":semirandom(23, 31)},
    {"name":"nyse",      "count":semirandom(36, 101)},
    {"name":"microsoft", "count":semirandom(14, 59)},
    {"name":"apple",     "count":semirandom(31, 98)},
    {"name":"google",    "count":semirandom(53, 119)}
  ]
rHashtags = -> 
  return [   
    {"name":"android",    "count":semirandom(15, 49)},
    {"name":"iphone/ios", "count":semirandom(11, 58)},
    {"name":"xiaomi",     "count":semirandom(23, 59)}
  ]
  
users = ->
  return [
    {"id":"u1", "name":"he9qi",   "count": semirandom(20, 60) },
    {"id":"u2", "name":"mjordan", "count": semirandom(70, 30) },
    {"id":"u3", "name":"kbryant", "count": semirandom(10, 90) },
    {"id":"u4", "name":"bobama",  "count": semirandom(40, 120)},
    {"id":"u5", "name":"sakura",  "count": semirandom(50, 100)},
    {"id":"u6", "name":"watashi", "count": semirandom(70, 90) },
    {"id":"u7", "name":"hujta",   "count": semirandom(70, 90) },
    {"id":"u8", "name":"hirocha", "count": semirandom(70, 90) },
    {"id":"u9", "name":"malasi",  "count": semirandom(70, 90) }
  ] 
rUsers = ->
  return [
    {"id":"ur1", "name":"rooney12","count": semirandom(23, 67) },
    {"id":"ur2", "name":"zorolen", "count": semirandom(13, 56) },
    {"id":"ur3", "name":"beckham", "count": semirandom(43, 81) }
  ]
  
tweets = ->
  return [
    {"id":"abc", "content":"Array Slicing and Splicing with Ranges", "count": semirandom(23, 59)},
    {"id":"def", "content":"Ranges can also be used to extract slices of arrays. ", "count":semirandom(11, 87)},
    {"id":"jkl", "content":"CoffeeScript provides the do keyword", "count":semirandom(20, 34)},
    {"id":"123", "content":"You might have noticed how even though we don't add return", "count":semirandom(34, 84)},
    {"id":"789", "content":"all statements in the language can be used as expressions.", "count":semirandom(40, 97)},
    {"id":"456", "content":"Comprehensions should be able to handle most places", "count":semirandom(34, 110)}
  ]
rTweets = ->
  return [
    {"id":"abc", "content":"London bridges falling down", "count": semirandom(42, 112)},
    {"id":"def", "content":"The accessor variant of the existential operator", "count":semirandom(32, 95)}
  ]
  
locations = -> 
  return [
    {"name":"chengdu",   "count": semirandom(9, 20) },
    {"name":"beijing",   "count": semirandom(22, 48) },
    {"name":"shanghai",  "count": semirandom(32, 89) },
    {"name":"los angeles", "count": semirandom(40, 110)},
    {"name":"new york",  "count": semirandom(54, 121)}
  ]
rLocations = ->
  return [
    {"name":"chicago",   "count": semirandom(19, 50) },
    {"name":"tibet",   "count": semirandom(11, 44) }
  ]
    
randomData = (timestamp, interval, step) ->
  timestamps = _.range timestamp-(interval-step), timestamp+step, step
  category  = "stock/finacial"
  
  usersArray = []
  tweetsArray = []
  hashtagsArray = []
  locationsArray = []
  
  for t in timestamps
    usersArray.push { "timestamp" : t,  "category" : category, "ranks" : occationalize(users(), rUsers()) }
    tweetsArray.push { "timestamp" : t,  "category" : category, "ranks" : occationalize(tweets(), rTweets()) }
    hashtagsArray.push { "timestamp" : t,  "category" : category, "ranks" : occationalize(hashtags(), rHashtags()) }
    locationsArray.push { "timestamp" : t,  "category" : category, "ranks" : occationalize(locations(), rLocations()) }
  return { "user" : usersArray, "tweet" : tweetsArray, "hashtag" : hashtagsArray, "location" : locationsArray }
  
exports.lastAllByTime = ( timestamp, interval, step, callback ) ->
  console.log "mock ranks @ #{timestamp} #{interval}, #{step}"  
  callback null, randomData(timestamp, interval, step)
  return 
