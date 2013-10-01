require "bundler/setup"
require 'httparty'
require 'json'

class Ranking
  include HTTParty
  
  base_uri 'http://localhost:3000/rankings'
  format :json
  
end

def semi_random(min, mod)
   (rand*mod+min).floor
end

def random_data
  trends = [
    [ "#ICEWEASELS", semi_random( 123, 50 ) ],
    [ "#ACE", semi_random( 98,  50 ) ],
    [ "#BELARUS", semi_random( 87,  50 ) ],  
    [ "#CHUMBUKIT", semi_random( 76,  50 ) ],      
    [ "#CANHAZ", semi_random( 65,  50 ) ],        
    [ "#YARR", semi_random( 54,  50 ) ],          
    [ "#YANILIVE", semi_random( 43,  50 ) ],            
    [ "#NONBELIEBER", semi_random( 32,  50 ) ],              
    [ "#YMMV", semi_random( 32,  50 ) ],              
    [ "#DEADBEEF", semi_random( 32,  50 ) ]              
  ]
  randoms    = [ "#THEDUDE", "#COWABUNGA", "#WOWSERS" , "#SHINJUKU" , "#NEEDIUM", "#MYFACE", "#BORING" ]
  occasion = (rand*2.floor) %2 == 1
  if occasion
    randidx   = (rand*randoms.length).floor
    trendidx  = (rand*trends.length).floor
    trends[ trendidx ][0] = randoms[randidx]
  end
  return { rankings: trends, timestamp: Time.now.to_i*1000 }
end

@@error_count = 0

def post_rankings
  begin
    puts random_data.to_json
    Ranking.post('/', 
        :body => random_data.to_json,
        :headers => { 'Content-Type' => 'application/json' } )
  rescue Errno::ECONNREFUSED
    puts "connection refused with error count #{@@error_count}\n"
    @@error_count = @@error_count + 1
  end
end

while true
  post_rankings
  t = ARGF.argv[0].to_i
  sleep t.is_a?(Integer) && t > 0 ? t : 3
end
  