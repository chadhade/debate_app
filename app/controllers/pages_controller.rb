class PagesController < ApplicationController
  skip_before_filter :record_activity_time, :only => [:landing, :login]
  
  def landing
  end

  def login
  end
end
