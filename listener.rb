$LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/redis-2.2.2/lib'
$LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/juggernaut-2.1.0/lib/'
$LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/json-1.6.1/lib'
require 'juggernaut'
require File.expand_path('../config/environment',  __FILE__)

ENV["REDIS_URL"] = 'redis://redistogo:97b231d432d6e9904bb55d43a3acd6a4@viperfish.redistogo.com:9543/'
Juggernaut.subscribe do |event, data|
  File.open("listener_log", 'a+') {|f| f.write("#{event}: #{data["channel"]}--------") }
  Debate.new.save
end
