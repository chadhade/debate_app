class ArgumentsController < ApplicationController

  def create    	
	@debate_id = params[:argument][:debate_id]
    @debate = Debate.find_by_id(@debate_id)
	@timeleft = time_left(@debate)
	
	# Check if argument is made on time
	if @timeleft > 0
		# create a new argument and redirect to debate page
		current_debater.arguments.create(:content => params[:argument][:content], :debate_id => params[:argument][:debate_id], :time_left => @timeleft)
		redirect_to debate_path(params[:argument][:debate_id])
	else
		# redirect without creating argument
		redirect_to debate_path(params[:argument][:debate_id])
		@debate.arguments.last.update_attributes(:Repeat_Turn => true)
	end		
  end
  
  def index
	@arguments = Argument.where("debate_id = ? and created_at > ?", params[:debate_id], Time.at(params[:after].to_i + 1))
	@debate = Debate.find_by_id(params[:debate_id])
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
