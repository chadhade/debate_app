class ArgumentsController < ApplicationController

  def create    	
  	@debate_id = params[:argument][:debate_id]
    @debate = Debate.find_by_id(@debate_id)
  	@lastargument = @debate.arguments.last	
  	@timeleft = time_left(@debate)
	
  	# Check if argument is made on time
  	if (@timeleft > 0) && (@debate.current_turn?(current_debater))
  		# create a new argument and redirect to debate page 
  		# -- Make the repeat_turn column true if it was true before
  		if @lastargument.Repeat_Turn == true 
  			@current_argument = current_debater.arguments.create(:content => params[:argument][:content], :debate_id => params[:argument][:debate_id], 
  										     :time_left => @timeleft, :Repeat_Turn => true)
  		else 
  		  # -- Don't make the repeat_turn column true
  			@current_argument = current_debater.arguments.create(:content => params[:argument][:content], 
  								:debate_id => params[:argument][:debate_id], :time_left => @timeleft) 
  		end
        
  		# Check if there are footnotes attached
  		@current_argument.has_footnote? ? @current_argument.save_footnote(@debate) : nil
  		
  		# publish new argument
  		  @debate = Debate.find_by_id(@debate.id) # Reset the debate variable now that new argument has been created
  		Juggernaut.publish("debate_" + @debate_id, data = {:timers => showtimers(@debate, @current_argument, @lastargument), 
  		                                                  :argument => render(@current_argument, :layout => false)}) 
  	end
  end
  
  def index
  	@arguments_params = parse_arguments_params_string(params[:arguments_params])
  	@arguments = new_arguments(@arguments_params)
	
  	# @debate = Debate.find_by_id(params[:debate_id])
  	# @debateid = @debate.id
  	@currentdebater = current_debater
	
  	@voting_params = parse_voting_params_string(params[:voting_params])
  	@votes = new_votes(@voting_params)
	
  	@debates = Array.new
  	@arguments_params.each {|debate_entry| @debates << debate_entry[:id]}
  	@currently_viewing_counts = updated_currently_viewing_counts(@debates)
  
  	# Add footnotes if they exist
  	@arguments.each do |debates|
  		debates[:new_arguments].each do |argument|
  			argument.any_footnotes ? argument.content = argument.show_footnote : nil
  		end
  	end
  end
  
  # create a hash of updated currently viewing counts:: :id => debate id, :currently_viewing_count => count
  def updated_currently_viewing_counts(debates)
    currently_viewing_counts = Array.new
  	@debates.each do |debate_id|
  	  currently_viewing_count = Viewing.where("debate_id = ? and currently_viewing = ?", debate_id, true).count
  	  currently_viewing_counts << {:id => debate_id, :currently_viewing_count => currently_viewing_count}
  	end
  	currently_viewing_counts
  end
  
  # parse arguments_params_string and put into an array of hashes:: :id => #, :after => last argument time
  def parse_arguments_params_string(params_string)
  	arguments_params = Array.new
  	params_string.split("@").each do |debate_entry|
  	  arguments_params << {:id => debate_entry.split(":")[0], :after => debate_entry.split(":")[1]} 
  	end
  	arguments_params
  end
  
  # get array of hashes with new arguments:: :id => #, :new_arguments => array of argument objects
  def new_arguments(arguments_params)
    arguments = Array.new
  	arguments_params.each do |debate_entry|
      debate_id = debate_entry[:id]
  	  new_arguments = Argument.where("debate_id = ? and created_at > ?", debate_entry[:id], Time.at(debate_entry[:after].to_i + 1))
  	  arguments << {:id => debate_id, :new_arguments => new_arguments} unless new_arguments.empty?
  	end
  	arguments
  end
  
  # parse voting_params_string and put into an array of hashes:: :id => 1, :times => {:for_time => x, :against_time => y}
  def parse_voting_params_string(params_string)
  	voting_params = Array.new
  	params_string.split("@").each do |arg_entry|
  	  voting_params << {:id => arg_entry.split(":")[0], :times => {:for_time => arg_entry.split(":")[1], :against_time => arg_entry.split(":")[2]}} 
  	end
  	voting_params
  end
  
  # get array of hashes with new values in @votes:: :id => 1, :updated_counts => {:for => x or nil, :against => y or nil}
  def new_votes(voting_params)
    votes = Array.new
  	voting_params.each do |arg_entry|
  	  argument = Argument.find(arg_entry[:id])
  	  new_for_entries = argument.votes.where("vote = ? and created_at > ?", "t", Time.at(arg_entry[:times][:for_time].to_i + 1))
  	  new_for_count = new_for_entries ? argument.votes_for : nil
  	  new_against_entries = argument.votes.where("vote = ? and created_at > ?", "f", Time.at(arg_entry[:times][:against_time].to_i + 1))
  	  new_against_count = new_against_entries ? argument.votes_against : nil
  	  votes << {:id => arg_entry[:id], :updated_counts => {:for => new_for_count, :against => new_against_count}}
  	end
  	votes
  end
  
  def showtimers(debate, argument_last, argument_second_last)
  	@previoustimeleft = argument_last.time_left
  	@currentdebater = current_debater
  	@debaters = debate.debaters
    
    # Calculate the amount of time left for use in javascript timers
  	# If there is only 1 debater, debater 2 has 0 seconds left
  	if @debaters.size == 1
  		@movingclock = 0
  		@staticclock = @previoustimeleft
  		@movingposition = 2  	    		
  		return {:movingclock => @movingclock, :staticclock => @staticclock, :movingposition => @movingposition, :debateid => debate.id}

  	end

  	@timeleft = time_left(debate)
  	#If a debater has run out of time, the other debater can continuously post
  	if (@timeleft <=0) && (argument_last.Repeat_Turn != true)
  		argument_last.update_attributes(:time_left => argument_last.time_left + argument_second_last.time_left, :Repeat_Turn => true)
  		@movingclock = argument_last.time_left - (Time.now - argument_last.created_at).seconds.to_i
  		@staticclock = 0
  		@movingposition = (argument_last.debater_id != debate.creator.id) ? 2 : 1
  		debate = Debate.find(params[:id]) # Reset the debate variable so the view can properly invoke "current_turn"
  		return {:movingclock => @movingclock, :staticclock => @staticclock, :movingposition => @movingposition, :debateid => debate.id}
  	end


    	# Calculate the amount of time left for use in javascript timers
    	# If there is only 1 debater, debater 2 has 0 seconds left
    	if debate.debaters.size == 1
    		@movingclock = 0
    		@staticclock = @previoustimeleft
    		@movingposition = 2
    		return {:movingclock => @movingclock, :staticclock => @staticclock, :movingposition => @movingposition, :debateid => debate.id}
    	end

    	#Otherwise, determine the order of debaters
    	argument_last.Repeat_Turn == true ? @previoustimeleft = 0 : nil
    	@movingclock = @timeleft 
    	@staticclock = @previoustimeleft
    	debate.current_turn == debate.creator ? @movingposition = 1 : @movingposition = 2
      return {:movingclock => @movingclock, :staticclock => @staticclock, :movingposition => @movingposition, :debateid => debate.id}
  end
  
end
