class DebatersController < ApplicationController
   before_filter :authenticate_debater!
   skip_before_filter :authenticate_debater! #, :only => [:show, :index]

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
    @debates = @debater.debates.where("end_time != ?", nil)
    
    @recentdebates = @debates.all(:order => "created_at DESC").first 5
    
    @debateswon = Judging.where("winner_id = ?", @debater.id).count
    @debateslost = Judging.where("loser_id = ?", @debater.id).count
    @debatesnoresults = @debates.count - (@debateswon + @debateslost)
        
    @positivevotes = 0
    @negativevotes = 0
    @arguments = 0
    
    @debates.each do |v|
      @arguments += v.arguments.where("debater_id = ?", @debater.id).count
    end
    
    @debater.arguments.each do |v|
      @positivevotes = @positivevotes + v.votes_for
      @negativevotes = @negativevotes + v.votes_against
    end
  end
  
  def index
    @title = "All Debaters"
    @debaters = Debater.paginate(:page => params[:page])
    @debaterranks = Array.new
    @debaters.each do |debater|
      rank = debater.rank
      @debaterranks << {:debater => debater, :rank => rank}
    end
    @debaterranks.sort!{|a,b| b[:rank] <=> a[:rank]}
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
    @debaters = Debater.teammates(@debater)
    @debaters.paginate(:page => params[:page])
    render 'show_network'
  end
  
end
