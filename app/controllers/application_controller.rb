class ApplicationController < ActionController::Base
  protect_from_forgery

  # include SessionsHelper in all controllers
  # they are in all views by default
  include SessionsHelper
  

	def time_left(thisdebate)
		@arglast = thisdebate.arguments.last
		
		if @arglast.Repeat_Turn == true
			@timeleft = @arglast.time_left - (Time.now - @arglast.created_at).seconds.to_i
		else
			@timeleft = thisdebate.arguments[-2].time_left - (Time.now - @arglast.created_at).seconds.to_i
		end
	end
  
  end
