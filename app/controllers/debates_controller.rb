class DebatesController < ApplicationController
  $total_debate_time = 6*60
  $individual_response_time = 1*60
  
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
	redirect_to @debate
  end
  
  def join
    # link debater to debate
	current_debater.debations.create(:debate_id => params[:id])
	
	#The amount of time Debater 2 has left.  
	@Seconds_Left_2 = (params[:argument][:time_left]).to_i * 60
	
	# create a new argument object
	@content_of_post = params[:argument][:content]
	@argument = current_debater.arguments.create(:content => @content_of_post, :debate_id => params[:id], :time_left => @Seconds_Left_2)
	
	redirect_to Debate.find(params[:id])
  end 
  
  def show
    # pull all arguments from that debate and pass debate object
	@debate = Debate.find(params[:id])
	@arguments = @debate.arguments
	
	# Calculate the amount of time left for use in javascript timers
	# If there is only 1 debater, debater 2 has 0 seconds left
	if @debate.debaters.size == 1
		@movingclock = 0
		@staticclock = @debate.arguments.last.time_left
		@movingposition = 2
	else
		#Otherwise, determine the order of debaters
		if @debate.current_turn == @debate.creator
			@movingclock = @debate.arguments[-2].time_left - (Time.now - @debate.arguments.last.created_at).seconds.to_i 
			@staticclock = @debate.arguments.last.time_left
			@movingposition = 1
		else
			@staticclock = @debate.arguments.last.time_left
			@movingclock = @debate.arguments[-2].time_left - (Time.now - @debate.arguments.last.created_at).seconds.to_i 
			@movingposition = 2
		end
	end
end
  
  def index
    # returns debates that match search criterion or all debates if empty string submitted
	@debates = Debate.search(params[:search])
	
	respond_to do |format|
	  format.html
	  format.js
	end
  end

end
