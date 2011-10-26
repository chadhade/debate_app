class DebatersController < ApplicationController

  def new
    @debater = Debater.new
  end
  
  def create
    @debater = Debater.new(params[:debater])
	# if the input was ok, go to show page
	# otherwise, go to new page
	redirect_to @debater and return if @debater.save
	render 'new'
  end
  
  def show
  end
  
end
