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
    @debates = @debater.debates
    
    @recentdebates = @debates.all(:order => "created_at DESC").first 5
    
    @debateswon = Judging.where("winner_id = ?", @debater.id).count
    @debateslost = Judging.where("loser_id = ?", @debater.id).count
    
    @positivevotes = 0
    @negativevotes = 0
    
    @debater.arguments.each do |v|
      @positivevotes = @positivevotes + v.votes_for
      @negativevotes = @negativevotes + v.votes_against
    end
  end
  
  def index
    @title = "All Debaters"
    @debaters = Debater.paginate(:page => params[:page])
  end
  
  def following
    @title = "Following"
    @debater = Debater.find(params[:id])
    @debaters = @debater.following.paginate(:page => params[:page])
    render 'show_network'
  end
  
  def followers
    @title = "Followers"
    @debater = Debater.find(params[:id])
    @debaters = @debater.followers.paginate(:page => params[:page])
    render 'show_network'
  end
  
  def is_blocking
    @title = "Blocking"
    @debater = Debater.find(params[:id])
    @debaters = @debater.is_blocking.paginate(:page => params[:page])
    render 'show_network'
  end
  
  def teammates
    @title = "Teammates"
    @debater = Debater.find(params[:id])
    @debaters = Debater.teammates(@debater).paginate(:page => params[:page])
    render 'show_network'
  end
  
end
