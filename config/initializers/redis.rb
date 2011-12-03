#uri = URI.parse(ENV["REDISTOGO_URL"])
#REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Redis.connect(:url => ENV['REDISTOGO_URL'])
