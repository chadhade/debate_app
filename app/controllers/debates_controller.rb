class DebatesController < ApplicationController
  # set load paths for redis and juggernaut
  if Rails.env.development?
    $LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/redis-2.2.2/lib'
    $LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/juggernaut-2.1.0/lib/'
  end

  require 'juggernaut'  
    
  def new
    # creating a new debate is the same as creating the first argument
  	@argument = Argument.new
  end
  
  def create
  	# create a new debate linked to debater
  	@debate = Debate.new
  	@debate.save
  	current_debater.debations.create(:debate_id => @debate.id)
	
  	# create a new argument object
  	@content_of_post = params[:argument][:content]
	
  	#The amount of time Debater 1 has left.  
  	@Seconds_Left_1 = (params[:argument][:time_left]).to_i * 60
		
  	@argument = current_debater.arguments.create(:content => @content_of_post, :debate_id => @debate.id, :time_left => @Seconds_Left_1)
	
  	# Check if there are footnotes attached
  	@argument.has_footnote? ? @argument.save_footnote(@debate) : nil
  	redirect_to @debate
  end
  
  def join
    @debate = Debate.find(params[:id])
  	# link debater to debate
  	current_debater.debations.create(:debate_id => params[:id])
	
  	#The amount of time Debater 2 has left.  
  	@Seconds_Left_2 = (params[:argument][:time_left]).to_i * 60
	
  	# create a new argument object
  	@content_of_post = params[:argument][:content]
  	@argument = current_debater.arguments.create(:content => @content_of_post, :debate_id => params[:id], :time_left => @Seconds_Left_2)
	
  	# Check if there are footnotes attached
  	@argument.has_footnote? ? @argument.save_footnote(@debate) : nil
	  
	  #Info for timers
	  @movingclock = @debate.arguments.first.time_left.to_i * 60
	  
	  # publish to appropriate channels
	  argument_render = render(@argument, :layout => false)
	  reset_invocation_response # allow double rendering
	  post_box_render = render(:partial => "arguments/form_argument", :locals => {:debate => @debate}, :layout => false)
	  reset_invocation_response # allow double rendering
	  
	  if Rails.env.production?
  	  Juggernaut.url = ENV['REDIS_URL'] 	  
	  end
	  

	  Juggernaut.publish("debate_" + params[:id], {:timers => {:movingclock => @movingclock, :staticclock => @Seconds_Left_2, :movingposition => 1, :debateid => @debate.id}, 
	                                              :argument => argument_render, :post_box => post_box_render, :current_turn => @debate.current_turn.email})
	  reset_invocation_response # allow double rendering
	  
	  respond_to do |format|
  	  format.html
  	  format.js {render :nothing => true}
  	end
  end 
  
############ allow double rendering ###################
def reset_invocation_response
  self.instance_variable_set(:@_response_body, nil)
end
#######################################################
  
  def show
    # pull all arguments from that debate and pass debate object

	@debate = Debate.find(params[:id])
	@arguments = @debate.arguments
	@argument_last = @arguments.last
	@previoustimeleft = @argument_last.time_left
	@currentdebater = current_debater
	@debaters = @debate.debaters
	
	debater_signed_in? ? @currentid = @currentdebater.id : @currentid = nil
	
	# for viewings
	update_viewings(@currentdebater, @debate)
	
	# Add footnotes if they exist
	@arguments.each do |argument|
		argument.any_footnotes ? argument.content = argument.show_footnote : nil
	end
	
	# Calculate the amount of time left for use in javascript timers
	# If there is only 1 debater, debater 2 has 0 seconds left
	if @debate.debaters.size == 1
		@movingclock = 0
		@staticclock = @previoustimeleft
		@movingposition = 2
	  @currentdebater == @debaters[0] ? @debater1 = "You" : @debater1 = @debaters[0].email
		@debater2 = "No one has joined"
		return
    
	end
	
	# Debater names
	@currentdebater == @debaters[0] ? @debater1 = "You" : @debater1 = @debaters[0].email
	@currentdebater == @debaters[1] ? @debater2 = "You" : @debater2 = @debaters[1].email
	
	@timeleft = time_left(@debate)
	#If a debater has run out of time, the other debater can continuously post
	if (@timeleft <=0) && (@argument_last.Repeat_Turn != true)
		@argument_last.update_attributes(:time_left => @argument_last.time_left + @arguments[-2].time_left, :Repeat_Turn => true)
		@movingclock = @argument_last.time_left - (Time.now - @argument_last.created_at).seconds.to_i
		@staticclock = 0
		@movingposition = (@argument_last.debater_id != @debate.creator.id) ? 2 : 1
		@debate = Debate.find(params[:id]) # Reset the debate variable so the view can properly invoke "current_turn"
		return
	end
	
  	#Otherwise, determine the order of debaters
  	@argument_last.Repeat_Turn == true ? @previoustimeleft = 0 : nil
  	@movingclock = @timeleft 
  	@staticclock = @previoustimeleft
  	@debate.current_turn == @debate.creator ? @movingposition = 1 : @movingposition = 2
  end

##############################################################################  
  def update_viewings(currentdebater, debates)
  	# set viewer variable
  	if currentdebater.nil?
  	  ip = Ip.new(:IP_address => request.remote_ip)
      ip = Ip.find_by_IP_address(request.remote_ip) unless ip.save
      viewer = ip
  	else
  	  viewer = currentdebater
  	end
  	# go through debates and update viewings for viewer and debate
  	if debates.kind_of?(Array)
  	  debates.each {|debate| update_viewings_for_viewer_debate(viewer, debate)}
  	else
  	  update_viewings_for_viewer_debate(viewer, debates)
  	end	
  end
  
  def update_viewings_for_viewer_debate(viewer, debate)
  	existing_viewing = viewer.viewings.where("debate_id = ?", debate.id)
  	if existing_viewing.empty?
  	  viewer.viewings.create(:debate_id => debate.id, :currently_viewing => true)
  	else
  	  existing_viewing.each {|viewing| viewing.update_attributes(:currently_viewing => true)} # unless existing_viewing.currently_viewing == true
  	end    
  end
##############################################################################  
  
  def index
    # returns debates that match search criterion or all debates if empty string submitted
  	@debates = Debate.search(params[:search])
	
  	respond_to do |format|
  	  format.html
  	  format.js
  	end
  end

end
