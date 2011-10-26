class ArgumentsController < ApplicationController

  def create
    # create a new argument and redirect to debate page
	current_debater.arguments.create(params[:argument])
	redirect_to debate_path(params[:argument][:debate_id])
  end
  
end
