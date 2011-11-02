class VotesController < ApplicationController
  def create
	@argument = Argument.find_by_id(params[:vote][:votable_id])
	@vote = params[:vote][:vote]
	current_debater.vote(@argument, :direction => :up) if @vote == "true"
	current_debater.vote(@argument, :direction => :down) if @vote == "false"
	respond_to do |format|
	  format.html
	  format.js {render :nothing => true}
	end	
  end

end
