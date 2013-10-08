require '../_helper'
assert   = require 'assert'
fs       = require 'fs'
path     = require 'path'
redis    = require('redis').createClient()
User     = require '../../app/models/user'

describe "User", ->
  
  userString = fs.readFileSync path.resolve(__dirname, '../sample/status.json'), { encoding: 'UTF-8', autoClose: true }
  userJson = (JSON.parse userString).user
  
  it "builds a key", ->
    assert.equal User.key(), 'ds:tweets:users'
  
  before (done) ->
    redis.hset User.key(), userJson.id, JSON.stringify(userJson)
    done()
    
  describe 'read user', ->
    user = null
    
    before (done) ->
      User.getById userJson.id, (err, _user) ->
        user = _user
        done()
        
    it 'gets user information', ->
      assert.equal user.profile_image_url, 'http://a1.twimg.com/profile_images/1540298033/phatkicks_normal.jpg'
      assert.equal user.name, 'fakekurrik'
      assert.equal user.location, ''
      assert.equal user.followers_count, 8
      assert.equal user.friends_count, 5
      assert.equal user.statuses_count, 142
      

