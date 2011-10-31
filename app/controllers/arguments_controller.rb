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
	end		
  end
  
  def index
    # @comments = Comment.where("article_id = ? and created_at > ?", params[:article_id], Time.at(params[:after].to_i + 1))
  end
  
end
