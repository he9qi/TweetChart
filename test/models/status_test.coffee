require '../_helper'
assert   = require 'assert'
fs       = require 'fs'
path     = require 'path'
redis    = require('redis').createClient()
Status   = require '../../app/models/status'

describe "Status", ->
  
  statusString = fs.readFileSync path.resolve(__dirname, '../sample/status.json'), { encoding: 'UTF-8', autoClose: true }
  statusJson = JSON.parse statusString
  
  it "builds a key", ->
    assert.equal Status.key(), 'ds:tweets:statuses'
  
  before (done) ->
    redis.hset Status.key(), statusJson.id, JSON.stringify(statusJson)
    done()
    
  describe 'read status', ->
    
    status = null
    
    before (done) ->
      Status.getById statusJson.id, (err, _status) ->
        status = _status
        done()
        
    it 'gets status information', ->
      assert.equal status.id, 174942523154894850
      assert.equal status.text, "Man I like me some @twitterapi"
      assert.equal status.created_at, 'Wed Feb 29 19:42:02 +0000 2012'
      assert.equal status.source, 'web'
      assert.equal status.retweet_count, 0
      # coordinates, place, geo
      
    it 'gets mentioned users information', ->
      mentioned_user = status.entities.user_mentions[0]
      assert.equal mentioned_user.name, "Twitter API"
      assert.equal mentioned_user.id, "6253282"
      assert.equal mentioned_user.screen_name, "twitterapi"
      
    it 'gets status user information', ->
      assert.equal status.user.profile_image_url, 'http://a1.twimg.com/profile_images/1540298033/phatkicks_normal.jpg'
      assert.equal status.user.name, 'fakekurrik'
      assert.equal status.user.location, ''
      assert.equal status.user.followers_count, 8
      assert.equal status.user.friends_count, 5
      assert.equal status.user.statuses_count, 142
      
      
  describe 'read statuses', ->

    statuses = null
    status   = null

    before (done) ->
      Status.getByIds [statusJson.id, statusJson.id], (err, _statuses) ->
        statuses = _statuses
        done()

    it 'gets status information', ->
      status = statuses[0]
      assert.equal status.id, 174942523154894850
      assert.equal status.text, "Man I like me some @twitterapi"
      assert.equal status.created_at, 'Wed Feb 29 19:42:02 +0000 2012'
      assert.equal status.source, 'web'
      assert.equal status.retweet_count, 0
  
      
      