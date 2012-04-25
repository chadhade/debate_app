class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :record_activity_time
   
  # include SessionsHelper in all controllers
  # they are in all views by default
  # include SessionsHelper
  
  # time left for person whose turn it is
	def time_left(thisdebate)
		arguments = thisdebate.arguments(:order => "created_at ASC")
		arglast = arguments.last(:order => "created_at ASC")
		
		if arglast.Repeat_Turn == true
			timeleft = arglast.time_left - (Time.now - arglast.updated_at).seconds.to_i
			return timeleft
		end
		
    if thisdebate.judge or thisdebate.no_judge == 3
  		# If there are only 2 arguments, use the 'started_at' field to determine when the debate started
  		if arguments.size == 2
  		  return arguments.first(:order => "created_at ASC").time_left - (Time.now - thisdebate.started_at).seconds.to_i
  		else
  		# Otherwise, use the time that the last argument was made
  			timeleft = thisdebate.arguments[-2].time_left - (Time.now - arglast.created_at).seconds.to_i
  		end
		else
		  return nil
	  end
	end
  
	def after_sign_in_path_for(resource)
		debater = current_debater
		debater.last_request_at = Time.now
		debater.current_sign_in_at = Time.now
		debater.rating.nil? ? debater.rating = 1000 : nil
		debater.save
		stored_location_for(resource) || "/pages/landing"
	end
 
	def after_sign_up_path_for(resource)
		debater = current_debater
		debater.last_request_at = Time.now
		debater.rating = 1000
		debater.save
		stored_location_for(resource) || "/pages/landing"
	end

	def after_sign_out_path_for(resource)
    debater = current_debater
    if debater
      debater.waiting_for = nil
      debater.current_sign_in_at = nil
      debater.save
      debater.clear_viewings if debater.viewings.any?
    end
    stored_location_for(resource) || "/debaters/sign_in"
  end
  
  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_debater
    if current_debater
      if session[:guest_debater_id]
        logging_in
        session[:guest_debater_id] = nil
      end
      current_debater
    else
      guest_debater unless self.controller_name == 'sessions' or self.controller_name == 'registrations'
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_debater
    debater = Debater.find(session[:guest_debater_id].nil? ? session[:guest_debater_id] = create_guest_debater.id : session[:guest_debater_id])
    debater.nil? ? debater = greate_guest_debater : debater
  end

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in
  end

  private

  def create_guest_debater
    u = Debater.new(:name => "guest#{(Time.now - 15380.days).to_i.to_s.reverse}#{rand(9)}", :email => "guest_#{Time.now.to_i}#{rand(99)}@debunky.com", :password => generated_password(8))
    u.confirmed_at = Time.now
    u.current_sign_in_at = Time.now
    u.last_request_at = Time.now
    u.rating = 1000
    u.save
    u
  end
 
  def generated_password(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    return Array.new(len){||chars[rand(chars.size)]}.join
  end
  
  #Update debater's activity time every 2 minutes
  def record_activity_time
    debater = current_or_guest_debater  
    return if !debater
    if debater.last_request_at
      if (Time.now > debater.last_request_at + 2.minutes)
        debater.last_request_at = Time.now
        debater.current_sign_in_at = Time.now if debater.current_sign_in_at.nil?
        debater.save
      end
    end
  end
  
 end
