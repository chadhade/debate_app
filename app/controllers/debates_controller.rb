class DebatesController < ApplicationController
  # set load paths for redis and juggernaut
  if Rails.env.development?
    $LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/redis-2.2.2/lib'
    $LOAD_PATH << '/opt/local/lib/ruby/gems/1.8/gems/juggernaut-2.1.0/lib/'
    require 'juggernaut'  
  end
  require 'will_paginate/array'
  
  #Global Variables
  $judgetime = 30.seconds
  $debatetime = 30.seconds
  
  #before_filter :authenticate_debater!
  #skip_before_filter :authenticate_debater!, :only => [:show, :index]
    
  def new
    
    # creating a new debate is the same as creating the first argument
  	@argument = Argument.new
  end
  
  def create
  	@currentdebater = current_or_guest_debater
  	# if debater was currently waiting for another debate, he is not allowed to create a new debate
  	if @currentdebater.waiting_for
  	  return
  	end
  	
  	# create a new debate linked to debater
  	  @debate = Debate.new(:joined => false, :judge => false, :creator_id => @currentdebater.id)
    	# Check if Debater agrees to start without a judge
    	  params[:argument][:Repeat_Turn] == 1.to_s ? @debate.no_judge = 1 : nil
    	@debate.save
    	@currentdebater.debations.create(:debate_id => @debate.id)
  	
  	# if debater was currently waiting for another debate, he now stops waiting
  	if @currentdebater.waiting_for
  	  @currentdebater.update_attributes(:waiting_for => nil)
  	end
  	
  	# update topic position with the debate id
  	@topic_position = TopicPosition.new(:debater_id => @currentdebater.id, :topic => params[:argument][:topic_position_topic], :position => params[:argument][:topic_position_position], :debate_id => @debate.id)
	  @topic_position.save
	  
  	# create a new argument object
  	@content_of_post = params[:argument][:content]
	
  	#The amount of time Debater 1 has left.  
  	@Seconds_Left_1 = $debatetime
		
  	@argument = @currentdebater.arguments.create(:content => @content_of_post, :debate_id => @debate.id, :time_left => @Seconds_Left_1)
  	
    # Juggernaut.publish("judging_index", {:append => {:debate_id => @debate.id}})
    # debate_link_unjoined = render(:partial => "/judgings/debate_link_unjoined", :locals => {:debate => @debate}, :layout => false)
    # Juggernaut.publish("judging_index", {:function => "append_to_unjoined", :debate_id => @debate.id, :object => debate_link_unjoined})
    # reset_invocation_response # allow double rendering
	
  	# Check if there are footnotes attached
  	@argument.has_footnote? ? @argument.save_footnote(@debate) : nil
  	redirect_to @debate
  end
  
  def join
    @currentdebater = current_or_guest_debater
    @guest = @currentdebater.guest?
    @debate = Debate.find(params[:id])
    
    # if debater was currently waiting for another debate, or is the creator, he is not allowed to join
  	if @currentdebater.waiting_for or @currentdebater.id == @debate.creator_id
  	  return
  	end
  	
    
  	# link debater to debate
  	@currentdebater.debations.create(:debate_id => params[:id])
    @currentid = @currentdebater.id
	
  	#The amount of time Debater 2 has left.  
  	@Seconds_Left_2 = $debatetime
  	
  	# create a new argument object
  	@content_of_post = params[:argument][:content]
  	@argument = @currentdebater.arguments.create(:content => @content_of_post, :debate_id => params[:id], :time_left => @Seconds_Left_2)
	
  	# update joined columns of debates
  	@debate.update_attributes(:joined => true, :joined_at => @argument.created_at, :joiner_id => @currentid)
  	
  	# update joiner column of viewings
  	update_viewings(@currentdebater, @debate, false, true)
	
  	# Check if there are footnotes attached
	  if @argument.has_footnote?
		  @argument.save_footnote(@debate)
		  @argument.content = @argument.show_footnote
		  @argfoot = true
		end
		
	  #Info for timers
	  @movingclock = @debate.arguments.first(:order => "created_at ASC").time_left.to_i * 60
	  
	  @debatestatus = @debate.status
	  
	  # publish to appropriate channels
	  argument_render = render(:partial => "arguments/argument", :locals => {:argument => @argument, :judgeid => @debate.judge_id, :currentid => @currentid, :status => @debatestatus, :debate => @debate}, :layout => false)
	  reset_invocation_response # allow double rendering
	  
	  waiting_icon_render = render(:partial => "debates/waiting", :locals => {:debate => @debate, :status => @debatestatus, :debater => @currentdebater, :participant => true}, :layout => false)
	  reset_invocation_response # allow double rendering
	  
    @argfoot == true ? footnotes_render = render(@debate.footnotes, :layout => false) : footnotes_render = false
	  
	  @guest ? joinerpath = @currentdebater.mini_name + " : " : joinerpath = "<a href=\"/debaters/#{@currentdebater.id.to_s}\">#{@currentdebater.mini_name}</a>"
	  @debatestatus[:status_code] == 3 ? current_turn = @debate.current_turn.name : current_turn = ""
	  Juggernaut.publish("debate_" + params[:id], {:func => "argument", :obj => {:timers => {:movingclock => @movingclock, :staticclock => @Seconds_Left_2, :movingposition => 1, :debateid => @debate.id}, 
	                                              :argument => argument_render, :current_turn => current_turn, 
	                                              :footnotes => footnotes_render, :judge_needed => @debate.started_at.nil?}})
	  
	  #Juggernaut.publish("debate_" + params[:id], {:func => "joiner", :obj => {:joiner => current_or_guest_debater.mini_name, :joinerpath => "/debaters/" + current_or_guest_debater.id.to_s, :waiting_icon => waiting_icon_render, :timers => {:movingclock => @movingclock, :staticclock => @Seconds_Left_2, :movingposition => 1, :debateid => @debate.id}}})
	  Juggernaut.publish("debate_" + params[:id], {:func => "joiner", :obj => {:joiner => @currentdebater.mini_name, :joinerpath => joinerpath, :joinerid => @currentid, :waiting_icon => waiting_icon_render, :timers => {:movingclock => @movingclock, :staticclock => @Seconds_Left_2, :movingposition => 1, :debateid => @debate.id}}})
	  reset_invocation_response # allow double rendering
	  
	  Juggernaut.publish("matches", {:func => "hide", :obj => @debate.id})
	  Juggernaut.publish("waiting_channel", {:func => "debate_update", :obj => {:debate => @debate.id, :status_value => @debatestatus[:status_value], :status_code => @debatestatus[:status_code]}})
	  
	  # update judgings index
    debate_link_joined = render(:partial => "/judgings/debate_link_joined", :locals => {:debate => @debate, :joined_no_judge => Array(Debate.judging_priority(1).last)}, :layout => false)	  
	  Juggernaut.publish("judging_index", {:function => "append_to_joined", :debate_id => @debate.id, :object => debate_link_joined}) if !@debate.judge
	  reset_invocation_response # allow double rendering
	  
	  # update status bar on show page
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_status", :obj => @debatestatus})
    
    # update individ status
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_exists", :obj => {:who_code => "debater2", :who_value => "Debunker2"}})
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater2", :who_value => "true", :who_message =>"A Debunker has joined this debate."}})
	  
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
  	@debateid = @debate.id
  	#@arguments = @debate.arguments(:order => "created_at ASC")
  	@arguments = @debate.arguments(:order => "created_at ASC").includes(:debater, :votes)
  	@argument_last = @arguments.last
  	@previoustimeleft = @argument_last.time_left
  	@currentdebater = current_or_guest_debater
  	@guest = @currentdebater.guest?
  	@debaters = @debate.debaters
	
  	#debater_signed_in? ? @currentid = @currentdebater.id : @currentid = nil
	  @currentid = @currentdebater.id
	  @is_creator = @debate.creator?(@currentdebater)
	  @is_joiner = @debate.joiner?(@currentdebater)
	  @is_judger = @debate.judger?(@currentdebater)
  	
  	# for viewings
  	if @is_creator or @is_joiner or @is_judger
  	  update_viewings(@currentdebater, @debate, @is_creator, @is_joiner)
  	  @participant = true
  	else
  	  @participant = false
  	end
  	
  	if !@currentdebater.nil?
    	if @is_creator and !@debate.joined?
    	  Juggernaut.publish("matches", {:func => "unhide", :obj => @debateid})
  	  end
	  end
  	
  	# set status
  	@status = @debate.status	  
    unless @currentdebater.nil?
      Juggernaut.publish("debate_" + @debateid.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater1", :who_value => "true", :who_message => "#{@currentdebater.mini_name} has arrived."}}) if @is_creator
    	Juggernaut.publish("debate_" + @debateid.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater2", :who_value => "true", :who_message => "#{@currentdebater.mini_name} has arrived."}}) if @is_joiner
    	Juggernaut.publish("debate_" + @debateid.to_s, {:func => "update_individual_cv", :obj => {:who_code => "judge", :who_value => "true", :who_message => "Judge has arrived."}}) if @is_judger
  	end
  	
  	#toggle waiting_for attribute if debater returns to that debate
  	if @currentdebater.waiting_for == params[:id].to_i
  	  @currentdebater.update_attributes(:waiting_for => nil)
  	end
  	
  	#toggle judgings index if applicable
  	#Juggernaut.publish("judging_index", {:function => "unhide_joined", :debate_id => @debateid}) if (@is_creator or @is_joiner) and @debate.currently_viewing(@debate.creator_id) and (@debate.currently_viewing(@debate.joiner_id) if (@debate.joined and @debate.no_judge != 3))
	  Juggernaut.publish("judging_index", {:function => "unhide_joined", :debate_id => @debateid}) if (@debate.joined and @debate.no_judge != 3) and ((@is_creator and @debate.currently_viewing(@debate.joiner_id)) or (@is_joiner and @debate.currently_viewing(@debate.creator_id)))
  	
  	# Add footnotes, if any exist
  	@arguments.each do |argument|
  		argument.any_footnotes ? argument.content = argument.show_footnote : nil
  	end
	
	  #Tally up the judge votes if the debate is over
	  @upvotes = 0
    @downvotes = 0
	  
    if !@debate.winner_id.nil?
      #@arguments.each do |argument|
        #@upvotes = @upvotes + argument.votes_for_by(@debate.judge_id)
        #@downvotes = @downvotes + argument.votes_against_by(@debate.judge_id)
      #end
      argument_ids = @arguments.collect{|a| a.id}
    
      @upvotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ? AND voter_id = ?", argument_ids, "Argument", true, @debate.judge_id).count
      @downvotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ? ANd voter_id = ?", argument_ids, "Argument", false, @debate.judge_id).count
    end
   
    
  	# Calculate the amount of time left for use in javascript timers
  	
    # If debate has ended, both debaters have 0 seconds left
    if @debate.end_time
      @movingclock = 0
      @staticclock = 0
      @movingposition = 0
      @creator = @debate.creator
      @joiner = @debate.joiner
      @is_creator ? @debater1name = "You" : @debater1name = @creator.mini_name
    	@is_joiner ? @debater2name = "You" : @debater2name = @joiner.mini_name
    	@voteable = true unless (@is_creator or @is_joiner)
    	return
    end
    
  	# If there is only 1 debater, debater 2 has 0 seconds left
  	if !@debate.joined
  		@movingclock = 0
  		@staticclock = @previoustimeleft
  		@movingposition = 2
  	  @creator = @debate.creator
  	  @is_creator ? @debater1name = "You" : @debater1name = @creator.mini_name
  		@debater2name = "Waiting"
  		@debatercount = 1
  		return
  	end
	
  	# Debater names
  	@creator = @debate.creator
    @joiner = @debate.joiner
  	@is_creator ? @debater1name = "You" : @debater1name = @creator.mini_name
  	@is_joiner ? @debater2name = "You" : @debater2name = @joiner.mini_name
	
	  # If no judge has joined, timers do not move (for judged debates)
	  if @debate.judge == false and @debate.no_judge != 3
	    @movingclock = @arguments.first(:order => "created_at ASC").time_left
	    @staticclock = @previoustimeleft
	    @movingposition = 0
	    return
	  end
	  
	  @voteable = true unless (@is_creator or @is_joiner) #We know there are 2 debaters and a judge (if requested). So, votes are allowed.
	  
  	@timeleft = time_left(@debate)
  	
  	#If a debater has run out of time, the other debater can continuously post
  	if (@timeleft <=0) && (@argument_last.Repeat_Turn != true)
  		@argument_last.update_attributes(:time_left => @argument_last.time_left + @arguments[-2].time_left, :Repeat_Turn => true)
  		@movingclock = @argument_last.time_left - (Time.now - @argument_last.created_at).seconds.to_i
  		@staticclock = 0
  		@movingposition = (@argument_last.debater_id != @debate.creator_id) ? 2 : 1
  		@debate = Debate.find(params[:id]) # Reset the debate variable so the view can properly invoke "current_turn"
  		return
  	end
	
  	#Otherwise, determine the order of debaters
  	@argument_last.Repeat_Turn == true ? @previoustimeleft = 0 : nil
  	@movingclock = @timeleft 
  	@staticclock = @previoustimeleft
  	@movingposition = 2
  	current_turn = @debate.current_turn
  	unless current_turn.nil?
  	  current_turn.id == @debate.creator_id ? @movingposition = 1 : nil
  	end
  end

##############################################################################  
  def update_viewings(currentdebater, debates, is_creator, is_joiner)
  	# set viewer variable
  	  viewer = currentdebater

  	# go through debates and update viewings for viewer and debate
  	if debates.kind_of?(Array)
  	  debates.each {|debate| update_viewings_for_viewer_debate(viewer, debate, is_creator, is_joiner)}
  	else
  	  update_viewings_for_viewer_debate(viewer, debates, is_creator, is_joiner)
  	end	
  end
  
  def update_viewings_for_viewer_debate(viewer, debate, creator, joiner)
  	existing_viewing = viewer.viewings.where("debate_id = ?", debate.id)
  	if existing_viewing.empty?
  	  viewer.viewings.create(:debate_id => debate.id, :currently_viewing => true, :creator => creator, :joiner => joiner)
  	else
  	  existing_viewing.each do |viewing| 
  	    viewing.update_attributes(:currently_viewing => true) unless viewing.currently_viewing
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
    	if !debate.end_time.nil? and debate.judge and debate.joined
    	  @debates_completed.unshift(debate)
    	else
    	  if debate.end_time.nil? and debate.judge and debate.joined
    	    timeleft = time_left(debate)
    	    @debates_ongoing.unshift(debate) if timeleft != nil and timeleft > 0
    	  end
    	end
    	
    	#@debates_ongoing.unshift(debate) if debate.end_time.nil? and debate.judge and debate.joined and time_left(debate) != nil and time_left(debate) > 0
      #@debates_completed.unshift(debate) if !debate.end_time.nil? and debate.judge and debate.joined
      #@debates_in_limbo.unshift(debate) if debate.end_time.nil? and (!debate.judge or !debate.joined)
	  end
	  
	  @debates_ongoing = @debates_ongoing.first(30)
	  @debates_ongoing = @debates_ongoing.paginate(:page => params[:ongoing_page], :per_page => 10) 
	  @debates_completed = @debates_completed.first(30)
	  @debates_completed = @debates_completed.paginate(:page => params[:completed_page], :per_page => 10)
	
	  @ajaxupdate = 1 if !params[:ongoing_page].nil?
    @ajaxupdate = 2 if !params[:completed_page].nil?
  	@ajaxupdate = 3 if !params[:search].nil?
  	
  	respond_to do |format|
  	  format.html
  	  format.js
  	end
  end
  
  def no_judge
    @debate = Debate.find(params[:id])
    
    if @debate.started_at.nil? 
      @currentdebater = current_or_guest_debater
      @debate.creator?(@currentdebater) ? iscreator = 1 : iscreator = 0
  	  @debate.joiner?(@currentdebater) ? isjoiner = 1 : isjoiner = 0
  	  
  	  if iscreator or isjoiner
  	    case @debate.no_judge
  	    when 0
  	      @debate.no_judge = (iscreator * 1) + (isjoiner * 2)
  	    when 1
  	      @debate.no_judge = (iscreator * 0) + (isjoiner * 3)
  	    when 2
  	      @debate.no_judge = (iscreator * 3) + (isjoiner * 0)
  	    end
  	    
  	    
  	    #no_judge_render = render(:partial => "/debates/form_no_judge", :locals => {:status => @debate.status, :debate => @debate, :is_creator => iscreator, :is_joiner => isjoiner}, :layout => false)
  	    #reset_invocation_response # allow double rendering
  	    case @debate.no_judge
	      when 0
	        text_nojudge = " "
	        @debate.save
  	    when 1
    			text_nojudge = "Debunker1 agrees to start without a Judge."
    			@debate.save
    		when 2
    			text_nojudge = "Debunker2 agrees to start without a Judge."
    			@debate.save
    		when 3
    		  text_nojudge = " "
    		  @debate.started_at = Time.now
    		  @debate.save
    		  
    		  @debatestatus = @debate.status
    		  #Start Timers
    		  firstarg = @debate.arguments.first(:order => "created_at ASC")
          secondarg = @debate.arguments.all(:order => "created_at ASC").second
          currentturn = @debate.creator.name
          Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "start_debate", :obj => {:timers => {:movingclock => firstarg.time_left, :staticclock => secondarg.time_left, :movingposition => 1, 
                            :debateid => @debate.id}, :current_turn => currentturn}})
          # remove debate from judging index page
          Juggernaut.publish("judging_index", {:function => "remove", :debate_id => @debate.id})
          # Publish to waiting channel
          Juggernaut.publish("waiting_channel", {:func => "debate_update", :obj => {:debate => @debate.id, :status_value => @debatestatus[:status_value], :status_code => @debatestatus[:status_code]}})
    		end
  	    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_status", :obj => @debatestatus ? @debatestatus : @debate.status, :obj2 => text_nojudge})
  	  end
    end
      
    respond_to do |format|
  	  format.html {render :nothing => true}
  	  format.js {render :nothing => true}
  	end
  end
  
  def end
    @debate = Debate.find(params[:id])
    @debateid = @debate.id
    arguments = @debate.arguments.all(:order => "created_at ASC").first(2)
    debatetime = arguments[0].time_left.seconds + arguments[1].time_left.seconds
    
    #Make sure this is only done once and that time is really up
    if @debate.status[:status_code] == 3 and (Time.now + 2.seconds > @debate.started_at + debatetime) #Allow a 2 second leeway
      @debate.update_attributes(:end_time => Time.now)
    
      if @debate.judge
        judgetime_div = render :partial => "/judgings/judging_timer"
        reset_invocation_response # allow double rendering    
        Juggernaut.publish("debate_" + @debateid.to_s, {:func => "judge_timer", :obj => {:judgetime_div => judgetime_div, :judgetime => $judgetime}})
        judging_form = render(:partial => "/judgings/judging_form", :locals => {:judging => @debate.judge_entry}, :layout => false)
        reset_invocation_response # allow double rendering
        Juggernaut.publish("debate_" + @debateid.to_s + "_judge", {:func => "judging_form", :obj => {:judging_form => judging_form}})    
      else
        Juggernaut.publish("debate_" + @debateid.to_s, {:func => "end_debate", :obj => {:joiner_id => @debate.joiner_id}})
      end
      
      # update status bar on show page
      Juggernaut.publish("debate_" + @debateid.to_s, {:func => "update_status", :obj => @debate.status})
    
    end
    
    respond_to do |format|
  	  format.html
  	  format.js {render :nothing => true}
  	end
  end

  def end_single
    @debate = Debate.find(params[:id])
    
    if time_left(@debate) <= 1 and !@debate.end_single_id # Make sure this is only called once and time is really up
      
      @debater_timeleft = params[:clock_position] == 1.to_s ? @debate.joiner : @debate.creator  # 1 = creator, 2 = joiner
      @debate.update_attributes(:end_single_id => params[:clock_position] == 1.to_s ? @debate.creator_id : @debate.joiner_id)
    
      @debate.arguments.where("debater_id = ?", @debater_timeleft.id).last(:order => "created_at ASC").update_attributes(:Repeat_Turn => true)
      @debate = Debate.find(params[:id])
    
  	  Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "end_single", :obj => {:current_turn => @debater_timeleft.name, :position => (params[:clock_position].to_i - 3).abs}})
    
      reset_invocation_response # allow double rendering
    end
    
    respond_to do |format|
  	  format.html
  	  format.js {render :nothing => true}
  	end
  end
  
  def end_judge
    @debate = Debate.find(params[:id])
    @debateid = @debate.id
    
    #Make sure this is only done once and that time is really up
    if @debate.end_time and Time.now + 2.seconds > @debate.end_time + $judgetime and @debate.participant?(current_or_guest_debater)
      # update status bar on show page
      Juggernaut.publish("debate_" + @debateid.to_s, {:func => "update_status", :obj => @debate.status})
      # Let participants chat
      Juggernaut.publish("debate_" + @debateid.to_s, {:func => "end_debate", :obj => {:joiner_id => @debate.joiner_id}})
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
