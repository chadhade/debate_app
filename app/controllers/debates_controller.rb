class DebatesController < ApplicationController
  # set load paths for redis and juggernaut
  if Rails.env.development?
    $LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/redis-2.2.2/lib'
    $LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/juggernaut-2.1.0/lib/'
    require 'juggernaut'  
  end
  
  #Global Variables
  $judgetime = 30.seconds
  $debatetime = 120.seconds
  
  #before_filter :authenticate_debater!
  #skip_before_filter :authenticate_debater!, :only => [:show, :index]
    
  def new
    
    # creating a new debate is the same as creating the first argument
  	@argument = Argument.new
  end
  
  def create
  	
  	# create a new debate linked to debater
  	@debate = Debate.new(:joined => false, :judge => false, :creator_id => current_or_guest_debater.id)
  	@debate.save
  	current_or_guest_debater.debations.create(:debate_id => @debate.id)
  	
  	# if debater was currently waiting for another debate, he now stops waiting
  	if current_or_guest_debater.waiting_for
  	  current_or_guest_debater.update_attributes(:waiting_for => nil)
  	end
  	
  	# update topic position with the debate id
  	@topic_position = TopicPosition.new(:debater_id => current_or_guest_debater, :topic => params[:argument][:topic_position_topic], :position => params[:argument][:topic_position_position])
  	#@topic_position = TopicPosition.find(params[:argument][:topic_position_id])
  	@topic_position.update_attributes(:debate_id => @debate.id)
	
  	# create a new argument object
  	@content_of_post = params[:argument][:content]
	
  	#The amount of time Debater 1 has left.  
  	@Seconds_Left_1 = $debatetime
		
  	@argument = current_or_guest_debater.arguments.create(:content => @content_of_post, :debate_id => @debate.id, :time_left => @Seconds_Left_1)
  	
    # Juggernaut.publish("judging_index", {:append => {:debate_id => @debate.id}})
    # debate_link_unjoined = render(:partial => "/judgings/debate_link_unjoined", :locals => {:debate => @debate}, :layout => false)
    # Juggernaut.publish("judging_index", {:function => "append_to_unjoined", :debate_id => @debate.id, :object => debate_link_unjoined})
    # reset_invocation_response # allow double rendering
	
  	# Check if there are footnotes attached
  	@argument.has_footnote? ? @argument.save_footnote(@debate) : nil
  	redirect_to @debate
  end
  
  def join
    
    @debate = Debate.find(params[:id])
  	# link debater to debate
  	current_or_guest_debater.debations.create(:debate_id => params[:id])
    @currentid = current_or_guest_debater.id
	
  	#The amount of time Debater 2 has left.  
  	@Seconds_Left_2 = $debatetime
  	
  	# if debater was currently waiting for another debate, he now stops waiting
  	if current_or_guest_debater.waiting_for
  	  current_or_guest_debater.update_attributes(:waiting_for => nil)
  	end
  	
  	# create a new argument object
  	@content_of_post = params[:argument][:content]
  	@argument = current_or_guest_debater.arguments.create(:content => @content_of_post, :debate_id => params[:id], :time_left => @Seconds_Left_2)
	
  	# update joined columns of debates
  	@debate.update_attributes(:joined => true, :joined_at => @argument.created_at, :joiner_id => current_or_guest_debater.id)
  	
  	# update joiner column of viewings
  	update_viewings(current_or_guest_debater, @debate)
	
  	# Check if there are footnotes attached
	  if @argument.has_footnote?
		  @argument.save_footnote(@debate)
		  @argument.content = @argument.show_footnote
		  @argfoot = true
		end
		
	  #Info for timers
	  @movingclock = @debate.arguments.first(:order => "created_at ASC").time_left.to_i * 60
	  
	  # publish to appropriate channels
	  argument_render = render(:partial => "arguments/argument", :locals => {:argument => @argument, :judgeid => @debate.judge_id, :currentid => @currentid, :status => @debate.status}, :layout => false)
	  reset_invocation_response # allow double rendering
	  
	  waiting_icon_render = render(:partial => "debates/waiting", :locals => {:debate => @debate}, :layout => false)
	  reset_invocation_response # allow double rendering
	  
    @argfoot == true ? footnotes_render = render(@debate.footnotes, :layout => false) : footnotes_render = false
	  
	  current_or_guest_debater.current_sign_in_at ? joinerpath = "<a href=\"/debaters/#{current_or_guest_debater.id.to_s}\">#{current_or_guest_debater.mini_name}</a>" : joinerpath = current_or_guest_debater.mini_name + " : "
	  
	  Juggernaut.publish("debate_" + params[:id], {:func => "argument", :obj => {:timers => {:movingclock => @movingclock, :staticclock => @Seconds_Left_2, :movingposition => 1, :debateid => @debate.id}, 
	                                              :argument => argument_render, :current_turn => @debate.current_turn.name, 
	                                              :footnotes => footnotes_render, :judge => @debate.judge}})
	  
	  #Juggernaut.publish("debate_" + params[:id], {:func => "joiner", :obj => {:joiner => current_or_guest_debater.mini_name, :joinerpath => "/debaters/" + current_or_guest_debater.id.to_s, :waiting_icon => waiting_icon_render, :timers => {:movingclock => @movingclock, :staticclock => @Seconds_Left_2, :movingposition => 1, :debateid => @debate.id}}})
	  Juggernaut.publish("debate_" + params[:id], {:func => "joiner", :obj => {:joiner => current_or_guest_debater.mini_name, :joinerpath => joinerpath, :waiting_icon => waiting_icon_render, :timers => {:movingclock => @movingclock, :staticclock => @Seconds_Left_2, :movingposition => 1, :debateid => @debate.id}}})
	  reset_invocation_response # allow double rendering
	  
	  Juggernaut.publish("matches", {:func => "hide", :obj => @debate.id})
	  Juggernaut.publish("waiting_channel", {:func => "debate_update", :obj => {:debate => @debate.id, :status_value => @debate.status[:status_value]}})
	  
	  # update judgings index
    debate_link_joined = render(:partial => "/judgings/debate_link_joined", :locals => {:debate => @debate, :joined_no_judge => Array(Debate.judging_priority(30).last)}, :layout => false)	  
	  Juggernaut.publish("judging_index", {:function => "append_to_joined", :debate_id => @debate.id, :object => debate_link_joined}) if !@debate.judge
	  reset_invocation_response # allow double rendering
	  
	  # update status bar on show page
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_status", :obj => @debate.status})
    
    # update individ status
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_exists", :obj => {:who_code => "debater2", :who_value => "Debater2"}})
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater2", :who_value => "true"}})
	  
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
  	@argument_last = @arguments.last(:order => "created_at ASC")
  	@previoustimeleft = @argument_last.time_left
  	@currentdebater = current_or_guest_debater
  	@debaters = @debate.debaters
	
  	#debater_signed_in? ? @currentid = @currentdebater.id : @currentid = nil
	  @currentid = @currentdebater.id
	  
  	# for viewings
  	if @debate.participant?(@currentdebater)
  	  update_viewings(@currentdebater, @debate)
  	end
  	
  	if !@currentdebater.nil?
    	if @currentdebater.creator?(@debate) and !@debate.joined?
    	  Juggernaut.publish("matches", {:func => "unhide", :obj => @debate.id})
  	  end
	  end
  	
  	# set status
  	@status = @debate.status	  
    unless @currentdebater.nil?
      Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater1", :who_value => "true"}}) if @currentdebater.creator?(@debate)
    	Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater2", :who_value => "true"}}) if @currentdebater.joiner?(@debate)
    	Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "judge", :who_value => "true"}}) if @currentdebater.judge?(@debate)
  	end
  	
  	#toggle waiting_for attribute if debater returns to that debate
  	if @currentdebater.waiting_for == params[:id].to_i
  	  @currentdebater.update_attributes(:waiting_for => nil)
  	end
  	
  	#toggle judgings index if applicable
  	Juggernaut.publish("judging_index", {:function => "unhide_joined", :debate_id => @debate.id}) if (@debate.creator?(@currentdebater) or @debate.joiner?(@currentdebater)) and @debate.currently_viewing("creator") and @debate.currently_viewing("joiner")
	  
  	# Add footnotes, if any exist
  	@arguments.each do |argument|
  		argument.any_footnotes ? argument.content = argument.show_footnote : nil
  	end
	
	  #Tally up the judge votes if the debate is over
	  @upvotes = 0
    @downvotes = 0
	  if @debate.end_time
	    if !@debate.judge_entry.winner_id.nil?
        @arguments.each do |argument|
          @upvotes = @upvotes + argument.votes_for_by(@debate.judge_id)
          @downvotes = @downvotes + argument.votes_against_by(@debate.judge_id)
        end
      end
    end
    
  	# Calculate the amount of time left for use in javascript timers
  	
    # If debate has ended, both debaters have 0 seconds left
    if @debate.end_time
      @movingclock = 0
      @staticclock = 0
      @movingposition = 0
      @currentdebater == @debaters[0] ? @debater1name = "You" : @debater1name = @debaters[0].mini_name
    	@currentdebater == @debaters[1] ? @debater2name = "You" : @debater2name = @debaters[1].mini_name
    	return
    end
    
  	# If there is only 1 debater, debater 2 has 0 seconds left
  	if @debaters.count == 1
  		@movingclock = 0
  		@staticclock = @previoustimeleft
  		@movingposition = 2
  	  @currentdebater == @debaters[0] ? @debater1name = "You" : @debater1name = @debaters[0].mini_name
  		@debater2name = "Waiting"
  		return
  	end
	
  	# Debater names
  	@currentdebater == @debaters[0] ? @debater1name = "You" : @debater1name = @debaters[0].mini_name
  	@currentdebater == @debaters[1] ? @debater2name = "You" : @debater2name = @debaters[1].mini_name
	
	  # If no judge has joined, timers do not move
	  if @debate.judge == false
	    @movingclock = @arguments.first(:order => "created_at ASC").time_left
	    @staticclock = @previoustimeleft
	    @movingposition = 0
	    return
	  end
	  
	  @voteable = true #At this point, we know there are 2 debaters and a judge.  Hence, votes are allowed.
	  
  	@timeleft = time_left(@debate)
  	
  	#If a debater has run out of time, the other debater can continuously post
  	if (@timeleft <=0) && (@argument_last.Repeat_Turn != true)
  		@argument_last.update_attributes(:time_left => @argument_last.time_left + @arguments[-2].time_left, :Repeat_Turn => true, :content => "test")
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
  	  viewer = currentdebater

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
  	  creator = viewer.class.name == 'Debater' ? debate.creator?(viewer) : false
  	  joiner = viewer.class.name == 'Debater' ? debate.joiner?(viewer) : false
  	  viewer.viewings.create(:debate_id => debate.id, :currently_viewing => true, :creator => creator, :joiner => joiner)
  	else
  	  existing_viewing.each do |viewing| 
  	    viewing.update_attributes(:currently_viewing => true) # unless existing_viewing.currently_viewing == true
  	    if viewer.class.name == 'Debater'
  	      viewing.update_attributes(:joiner => true) if viewing.debate.joiner?(viewer)
	      end
	    end
  	end    
  end
##############################################################################  
  
  def index
    # returns debates that match search criterion or all debates if empty string submitted
  	@debates = Debate.search(params[:search]).last(100)
  	
  	@debates_ongoing = Array.new
    @debates_in_limbo = Array.new
    @debates_completed = Array.new

    @debates.each do |debate|
    	@debates_ongoing.unshift(debate) if debate.end_time.nil? and debate.judge and debate.joined and time_left(debate) != nil and time_left(debate) > 0
      @debates_completed.unshift(debate) if !debate.end_time.nil? and debate.judge and debate.joined
      @debates_in_limbo.unshift(debate) if debate.end_time.nil? and (!debate.judge or !debate.joined)
	  end
	  
	  @debates_ongoing = @debates_ongoing.first(50)
	  @debates_ongoing = @debates_ongoing.paginate(:page => params[:ongoing_page], :per_page => 10)
	  @debates_completed = @debates_completed.first(50)
	  @debates_completed = @debates_completed.paginate(:page => params[:completed_page], :per_page => 10)
	
	  @ajaxupdate = 1 if !params[:ongoing_page].nil?
    @ajaxupdate = 2 if !params[:completed_page].nil?
  	@ajaxupdate = 3 if !params[:search].nil?
  	
  	respond_to do |format|
  	  format.html
  	  format.js
  	end
  end
  
  def end
    @debate = Debate.find(params[:id])
    
    @debate.update_attributes(:end_time => Time.now)
    
    judgetime_div = render :partial => "/judgings/judging_timer"
    reset_invocation_response # allow double rendering    
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "judge_timer", :obj => {:judgetime_div => judgetime_div, :judgetime => $judgetime}})
    judging_form = render(:partial => "/judgings/judging_form", :locals => {:judging => @debate.judge_entry}, :layout => false)
    reset_invocation_response # allow double rendering
    Juggernaut.publish("debate_" + @debate.id.to_s + "_judge", {:func => "judging_form", :obj => {:judging_form => judging_form}})    
    
    # update status bar on show page
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_status", :obj => @debate.status})
    
    respond_to do |format|
  	  format.html
  	  format.js {render :nothing => true}
  	end
  end

  def end_single
    @debate = Debate.find(params[:id])
    @debater_timeleft = params[:clock_position] == 1.to_s ? @debate.joiner : @debate.creator  # 1 = creator, 2 = joiner
    @debate.update_attributes(:end_single_id => params[:clock_position] == 1.to_s ? @debate.creator.id : @debate.joiner.id)
    
    @debate.arguments.where("debater_id = ?", @debater_timeleft.id).last(:order => "created_at ASC").update_attributes(:Repeat_Turn => true)
    @debate = Debate.find(params[:id])
    
	  Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "end_single", :obj => {:current_turn => @debate.current_turn.email, :position => (params[:clock_position].to_i - 3).abs}})
    
    reset_invocation_response # allow double rendering
    
    respond_to do |format|
  	  format.html
  	  format.js {render :nothing => true}
  	end
  end
  
  def end_judge
    @debate = Debate.find(params[:id])
    
      unless @debate.judge_entry.winner_id
        # update status bar on show page
        Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_status", :obj => @debate.status})
    
        # Provide all participants with ability to chat, if judge's submission did not do this already
          Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "end_debate", :obj => {joiner_id => @debate.joiner.id}})
      end
      
        respond_to do |format|
      	  format.html {render :nothing => true}
      	  format.js {render :nothing => true}
      	end
  end
  
  def waiting
    current_or_guest_debater.update_attributes(:waiting_for => params[:id].to_i)
    redirect_to debates_path
  end
  
end
