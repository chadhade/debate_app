uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Redis.connect(:url => "redis://redistogo:5439f70de5e485ed6ec83e26cc28edde@stingfish.redistogo.com:9222/")