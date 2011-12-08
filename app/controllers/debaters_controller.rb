class DebatersController < ApplicationController

  def new
    @debater = Debater.new
  end
  
  def create
    @debater = Debater.new(params[:debater])
	  if @debater.save	  
	    sign_in @debater
	    redirect_to debates_path
	  else
	    render 'new'
	  end
  end
  
  def show
    @debater = Debater.find(params[:id])
  end
  
  def index
    @title = "All Debaters"
    @debaters = Debater.paginate(:page => params[:page])
  end
  
  def following
    @title = "Following"
    @debater = Debater.find(params[:id])
    @debaters = @debater.following.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @debater = Debater.find(params[:id])
    @debaters = @debater.followers.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def is_blocking
    @title= "Blocking"
    @debater = Debater.find(params[:id])
    @debaters = @debater.is_blocking.paginate(:page => params[:page])
    render 'show_follow'
  end
  
end
