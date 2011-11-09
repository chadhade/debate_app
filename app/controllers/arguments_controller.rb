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
			current_debater.arguments.create(:content => params[:argument][:content], :debate_id => params[:argument][:debate_id], 
										     :time_left => @timeleft, :Repeat_Turn => true)
		else 
		  # -- Don't make the repeat_turn column true
			current_debater.arguments.create(:content => params[:argument][:content], :debate_id => params[:argument][:debate_id], :time_left => @timeleft) 
		end
		redirect_to debate_path(params[:argument][:debate_id])
	else
		# redirect without creating argument
		redirect_to debate_path(params[:argument][:debate_id])
	end		
  end
  
  def index
	@arguments = Argument.where("debate_id = ? and created_at > ?", params[:debate_id], Time.at(params[:after].to_i + 1))
	@debate = Debate.find_by_id(params[:debate_id])
	@debateid = @debate.id
	@currentdebater = current_debater
	
	@voting_params = parse_voting_params_string(params[:voting_params])
	@votes = new_votes(@voting_params)
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
  
  # for long polling, not used right now
  def check_for_new_args(debate_id, after, increment, timeout_length)
	sleep(increment)
	@arguments = Argument.where("debate_id = ? and created_at > ?", debate_id, after)    
	t = 0
	t += increment
	until t > timeout_length || !@arguments.empty?
	  sleep(increment)
	  @arguments = Argument.where("debate_id = ? and created_at > ?", debate_id, after)
	  t += increment
	end
  end
  
end
