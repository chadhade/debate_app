class VotesController < ApplicationController
  def create
    # current_debater.vote(@argument, true or false)
	respond_to do |format|
	  format.html
	  format.js
	end	
  end

end
