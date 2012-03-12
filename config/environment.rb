# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DebateApp::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :address  => "smtp.gmail.com",
  :port  => 587,
  :user_name  => "debunky",
  :password  => "banana03",
  :authentication  => :login
}

