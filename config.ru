# This file is used by Rack-based servers to start the application.

#require ::File.expand_path('../config/environment',  __FILE__)
#run DebateApp::Application

#Added to work with Heroku (2/25/12)

require ::File.expand_path('../config/environment',  __FILE__)

use Rails::Rack::LogTailer
#use Rails::Rack::Static
#run ActionController::Dispatcher.new
run DebateApp::Application