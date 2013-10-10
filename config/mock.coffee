_        = require 'underscore'
fs       = require 'fs'
path     = require 'path'

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
    {"name":"u1", "count": semirandom(20, 60) },
    {"name":"u2", "count": semirandom(70, 30) },
    {"name":"u3", "count": semirandom(10, 90) },
    {"name":"u4", "count": semirandom(40, 120)},
    {"name":"u5", "count": semirandom(50, 100)},
    {"name":"u6", "count": semirandom(70, 90) },
    {"name":"u7", "count": semirandom(70, 90) },
    {"name":"u8", "count": semirandom(70, 90) },
    {"name":"u9", "count": semirandom(70, 90) }
  ] 
rUsers = ->
  return [
    {"name":"ur1", "count": semirandom(23, 67) },
    {"name":"ur2", "count": semirandom(13, 56) },
    {"name":"ur3", "count": semirandom(43, 81) }
  ]
  
tweets = ->
  return [
    {"name":"174942523154894850", "count": semirandom(23, 59)},
    {"name":"xxx", "count":semirandom(11, 87)},
    {"name":"jkl", "count":semirandom(20, 34)},
    {"name":"123", "count":semirandom(34, 84)},
    {"name":"789", "count":semirandom(40, 97)},
    {"name":"456", "count":semirandom(34, 110)},
    {"name":"yyy", "count":semirandom(40, 120)}
  ]
rTweets = ->
  return [
    {"name":"abc", "count": semirandom(42, 112)},
    {"name":"def", "count":semirandom(32, 95)}
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

userHead = ->
  return [
    "https://si0.twimg.com/profile_images/3609491522/388703f14207ddbb9d4f7e56f6644835_normal.png",
    "https://si0.twimg.com/profile_images/926771803/KFC_Col_prc.eps_normal.jpg",
    "https://si0.twimg.com/profile_images/2285149580/1sf5l3214h2pfbz7d5bs_normal.jpeg",
    "https://si0.twimg.com/profile_images/344513261579555483/c735576e8913eb6fbf9ec3d35b74dbcc_normal.jpeg",
    "https://si0.twimg.com/profile_images/378800000365921985/eba230fde636f1c825558884a698453e_normal.jpeg",
    "https://si0.twimg.com/profile_images/1589711380/Steve_Park_final_normal.jpg",
    "https://si0.twimg.com/profile_images/3782037784/7a63f8672f18c550b1e2b7f127732bfa_normal.jpeg",
    "https://si0.twimg.com/profile_images/378800000195279414/f8404a9d719c7ffce1478ba1a50036f9_normal.png",
    "https://si0.twimg.com/profile_images/1709366033/image_normal.jpg",
    "https://si0.twimg.com/profile_images/1422223766/mdo-upside-down-shades_normal.jpg",
    "https://si0.twimg.com/profile_images/378800000534133188/42ea74a0b301758d08e5d06f2a64f04e_normal.jpeg",
    "https://si0.twimg.com/profile_images/704174520/xer_primary_avatar_gold_normal.jpg",
    "https://si0.twimg.com/profile_images/378800000542992631/2eb2ada536e9b0832a6bc99672bd74dc_normal.jpeg",
    "https://si0.twimg.com/profile_images/378800000364201669/4e1761d8b8d38cf205fa6d3a60a61d6a_normal.png",
    "https://si0.twimg.com/profile_images/59268975/jquery_avatar_normal.png",
    "https://si0.twimg.com/profile_images/2683779262/71dbd2d6fd6dc549b1d33e32131c14dd_normal.jpeg",
    "https://si0.twimg.com/profile_images/378800000534522357/4ff06cd58c2332ea8bcda23214d14842_normal.jpeg",
    "https://si0.twimg.com/profile_images/3725014716/5bf1578383c67f921508700ea1b0d02e_normal.png"
  ]  
  
statusString = fs.readFileSync path.resolve(__dirname, '../test/sample/status.json'), { encoding: 'UTF-8', autoClose: true }
statusJson = JSON.parse statusString 
  
mUsers = ->
  allUsers = _.union users(), rUsers()
  hash = {}
  userImages = userHead()
  for _user, index in allUsers
    userJsonNew = (JSON.parse statusString).user
    userJsonNew.id = _user.name # name is the id for tops
    userJsonNew.profile_image_url = userImages[ index % userImages.length ]
    userJsonNew.followers_count = semirandom(500, 8000)
    userJsonNew.friends_count = semirandom(1400, 7000)
    userJsonNew.statuses_count = semirandom(2400, 10000)
    hash[userJsonNew.id] = userJsonNew
  return hash

mTweets = ->
  allTweets = _.union tweets(), rTweets()
  hash = {}
  userImages = userHead()
  for _tweet, index in allTweets
    statusJsonNew = JSON.parse statusString 
    statusJsonNew.id_str = _tweet.name # name is the id for tops
    statusJsonNew.user.profile_image_url = userImages[ index % userImages.length ]
    hash[statusJsonNew.id_str] = statusJsonNew
  return hash
    
randomData = (timestamp, interval, step) ->
  timestamps = _.range timestamp-(interval-step), timestamp+step, step
  category  = "stock/finacial"
  
  usersArray = []
  tweetsArray = []
  hashtagsArray = []
  locationsArray = []
  exposureArray = []
  
  for t in timestamps
    usersArray.push { "timestamp" : t,  "category" : category, "ranks" : occationalize(users(), rUsers()),    "models" : mUsers() }
    tweetsArray.push { "timestamp" : t,  "category" : category, "ranks" : occationalize(tweets(), rTweets()), "models" : mTweets() }
    hashtagsArray.push { "timestamp" : t,  "category" : category, "ranks" : occationalize(hashtags(), rHashtags()) }
    locationsArray.push { "timestamp" : t,  "category" : category, "ranks" : occationalize(locations(), rLocations()) }
    exposureArray.push { "timestamp" : t, "value" : semirandom(2000000, 500000) }
  return { "user" : usersArray, "tweet" : tweetsArray, "hashtag" : hashtagsArray, "location" : locationsArray, "exposure" : exposureArray }
  
exports.lastAllByTime = ( rank_array, timestamp, interval, step, callback ) ->
  console.log "mock ranks @ #{timestamp} #{interval}, #{step}"  
  callback null, randomData(timestamp, interval, step)
  return 
