class PagesController < ApplicationController
  skip_before_filter :record_activity_time, :only => [:landing, :login]
  
  def landing
    @trending = Suggested_Topic.trending(6)
  end

  def login
  end
end
