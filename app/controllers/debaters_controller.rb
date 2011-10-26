class DebatersController < ApplicationController

  def new
    @debater = Debater.new
  end
  
  def create
    @debater = Debater.new(params[:debater])
	if @debater.save	  
	  sign_in @debater
	  redirect_to @debater
	else
	  render 'new'
	end
  end
  
  def show
  end
  
end
