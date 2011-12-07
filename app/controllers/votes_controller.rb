class VotesController < ApplicationController
  def create
	  @argument = Argument.find_by_id(params[:argument_id])
	  @vote = params[:vote]
	  @debate_id = params[:debate_id]
	
	  current_debater.vote(@argument, :direction => :up) if @vote == "true"
	  current_debater.vote(@argument, :direction => :down) if @vote == "false"
	  
	  Juggernaut.publish("debate_" + @debate_id + "_votes", {:id => params[:argument_id], :type => @vote})
	  
	  respond_to do |format|
	    format.html
	    format.js {render :nothing => true}
	  end	
  end
end
