class DebatesController < ApplicationController
    
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
	@argument_last = @arguments.last
	@previoustimeleft = @argument_last.time_left
	@currentdebater = current_debater
	debater_signed_in? ? @currentid = @currentdebater.id : @currentid = nil
	
	# Calculate the amount of time left for use in javascript timers
	# If there is only 1 debater, debater 2 has 0 seconds left
	if @debate.debaters.size == 1
		@movingclock = 0
		@staticclock = @previoustimeleft
		@movingposition = 2
		return
	end
	
	@timeleft = time_left(@debate)
	#If a debater has run out of time, the other debater can continuously post
	if (@timeleft <=0) && (@argument_last.Repeat_Turn != true)
		@argument_last.update_attributes(:time_left => @argument_last.time_left + @arguments[-2].time_left, :Repeat_Turn => true)
		@movingclock = @argument_last.time_left - (Time.now - @arglast.created_at).seconds.to_i
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
  
  def index
    # returns debates that match search criterion or all debates if empty string submitted
	@debates = Debate.search(params[:search])
	
	respond_to do |format|
	  format.html
	  format.js
	end
  end

end
