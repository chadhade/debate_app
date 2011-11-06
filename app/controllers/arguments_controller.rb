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
