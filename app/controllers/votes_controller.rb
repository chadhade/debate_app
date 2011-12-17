class VotesController < ApplicationController
  def create
	  @argument = Argument.find_by_id(params[:argument_id])
	  @vote = params[:vote]
	  @debate_id = params[:debate_id]
	  @debate = Debate.find_by_id(@debate_id)
	  
	  current_debater.vote(@argument, :direction => :up) if @vote == "true"
	  current_debater.vote(@argument, :direction => :down) if @vote == "false"
	  
	  if current_debater.id != @debate.judge_entry.debater_id
	    Juggernaut.publish("debate_" + @debate_id + "_votes", {:func => "viewer_votes", :obj => {:id => params[:argument_id], :type => @vote}})
	  else
	    Juggernaut.publish("debate_" + @debate_id + "_judge", {:func => "judge_votes", :obj => {:votes => {:id => params[:argument_id], :type => @vote}}})
	  end
	  
	  respond_to do |format|
	    format.html
	    format.js {render :nothing => true}
	  end	
  end
end
