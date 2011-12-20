class ApplicationController < ActionController::Base
  protect_from_forgery

  # include SessionsHelper in all controllers
  # they are in all views by default
  # include SessionsHelper
  

	def time_left(thisdebate)
		arguments = thisdebate.arguments(:order => "created_at ASC")
		arglast = arguments.last
		
		# If there are only 2 arguments, you know the timers first started as soon as the judge joined
		if arguments.count == 2
		  return arguments.first.time_left - (Time.now - thisdebate.judge_entry.created_at).seconds.to_i
		end
		
		# Otherwise, the timers started when the last argument was made
		if arglast.Repeat_Turn == true
			timeleft = arglast.time_left - (Time.now - arglast.updated_at).seconds.to_i
		else
			timeleft = thisdebate.arguments[-2].time_left - (Time.now - arglast.created_at).seconds.to_i
		end
	end
  
	def after_sign_in_path_for(resource)
		stored_location_for(resource) || "/pages/landing"
	end
 
	def after_sign_up_path_for(resource)
		stored_location_for(resource) || "/pages/landing"
	end
 end
