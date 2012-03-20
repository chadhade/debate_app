class DebatersController < ApplicationController
   before_filter :authenticate_debater!
   skip_before_filter :authenticate_debater! , :only => [:sign_in, :sign_up, :index]
   skip_before_filter :record_activity_time, :only => [:sign_in, :sign_up]
   
   require 'will_paginate/array'
   
  def new
    @debater = Debater.new
    @image = "http://railslab.newrelic.com/images/theme/masthead-scalingrails.png?1318048919\" width=\"50\""
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
    
    #Cannot view profile page of guests
    if @debater.guest? 
      redirect_to topic_positions_path
    end
    
    # Individual Stats
      if Rails.env.development? or Rails.env.test?
        @debates = @debater.debates.where("end_time > ?", 0)
      else
        @debates = @debater.debates.where("end_time > ?", "01/01/01")
      end
    
      @recentdebates = @debates.all(:order => "created_at DESC").last(30)
      @recentdebates = @recentdebates.paginate(:page => params[:page], :per_page => 10)
      
      @debateswon = @debates.where("winner_id = ?", @debater.id).count
      @debateslost = @debates.where("loser_id = ?", @debater.id).count
      @debatestied = @debates.where("winner_id = ?", 0).count
      @debatesnoresults = @debates.count - (@debateswon + @debateslost + @debatestied)
      @debaterjudgings = Judging.where("debater_id = ? AND winner_id >= ?", @debater.id, 0).count  
      
      argument_ids = @debater.arguments.collect{|u| u.id}
      @positivevotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ?", argument_ids, "Argument", true).count
      @negativevotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ?", argument_ids, "Argument", false).count
      
    # Team Stats
      @teammates = Debater.teammates(@debater)
      
      if !@teammates.empty? # Only perform calculations if debater has teammates
        @teammates << @debater
        team_ids = @teammates.collect{|u| u.id}
        teamargument_ids = Argument.where(:debater_id => team_ids).collect(&:id)
      
        if Rails.env.development? or Rails.env.test?
          @tdebates = Debate.where("(creator_id IN (?) OR joiner_id IN (?)) AND end_time > ?", team_ids, team_ids, 0)
          @teamdebates = @tdebates.count
        else
          @tdebates = Debate.where("(creator_id IN (?) OR joiner_id IN (?)) AND end_time > ?", team_ids, team_ids, "01/01/01")
          @teamdebates = @tdebates.count
        end
        
        @teamjudgepoints = Debater.where("id IN (?)", team_ids).sum(:judge_points)
        
        @teamdebateswon = @tdebates.where("winner_id IN (?)", team_ids).count
        @teamdebateslost = @tdebates.where("loser_id IN (?)", team_ids).count
        @teamdebatestied = @tdebates.where("winner_id = ?", 0).count
        @teamdebatesnoresults = @teamdebates - (@teamdebateswon + @teamdebateslost + @teamdebatestied)
        @teamjudgings = Judging.where("debater_id IN (?) AND winner_id >= ?", team_ids, 0).count
      
        @teampositivevotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ?", teamargument_ids, "Argument", true).count
        @teamnegativevotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ?", teamargument_ids, "Argument", false).count
      
      end
      
      @following = @debater.following
      @following.empty? ? return : nil # Exit if there are no 'followees'
      
      follow_ids = @following.collect{|u| u.id}
      #@following.each do |debater|
        #debater.debates.all(:order => "id DESC").first(20).each do |debate|
          #follow_ids << debate.id
        #end
      #end
      
      @followdebates = Debate.where("creator_id IN (?) or joiner_id IN (?)", follow_ids, follow_ids)
      @followdebates = @followdebates.all(:order => "updated_at DESC").first(30)
      @followdebates = @followdebates.paginate(:page => params[:following_page], :per_page => 8)
      
      @ajaxupdate = 1 if !params[:page].nil?
      @ajaxupdate = 2 if !params[:following_page].nil?
      respond_to do |format|
          format.html 
          format.js
        end
  end
  
  def index
    @title = "All Debaters"
    debaters = Debater.where("sign_in_count > ?", 0)
    @debaterranks = Array.new
    
    if !debaters.empty?
      debaters.each do |debater|
        rank = debater.rank
        @debaterranks << {:debater => debater, :rank => rank, :joined => debater.created_at, :judge_points => debater.judge_points}
      end
      #@debaterranks.sort!{|a,b| b[:rank] <=> a[:rank]}
      @debaterranks = @debaterranks.sort_by{ |a| [ a[:debater][:rating], a[:rank], a[:judge_points] ] }.reverse!
      @debaterranks = @debaterranks.paginate(:page => params[:page], :per_page => 15)
    end
    
    respond_to do |format|
        format.html 
        format.js
      end
  end
  
  def following
    @title = "Following"
    @debater = Debater.find(params[:id])
    @debaters = @debater.following
    
    if current_or_guest_debater == @debater
      teammates = Debater.teammates(@debater)
      nonteammates = @debaters - teammates
      nonteammates.each do |debater|
        if Relationship.where("follower_id = ? AND followed_id = ?", @debater.id, debater.id).first.teammate == true
          debater.sign_in_count = -2 #Unique way to identify those who have received a teammate request
        end
      end
      
      teammates.each do |mate|
        mate.sign_in_count = -1 #Unique way to identify teammates
      end
      @debaters = (teammates + nonteammates).paginate(:page => params[:page], :per_page => 15)
      render 'show_network_team'
    else
      @debaters = @debaters.paginate(:page => params[:page], :per_page => 15)
      render 'show_network'
    end
  end
  
  def followers
    @title = "Followers"
    @debater = Debater.find(params[:id])
    @debaters = @debater.followers.paginate(:page => params[:page], :per_page => 15)
    render 'show_network'
  end
  
  def is_blocking
    @title = "Blocking"
    @debater = Debater.find(params[:id])
    @debaters = @debater.is_blocking.paginate(:page => params[:page], :per_page => 15)
    render 'show_network'
  end
  
  def teammates
    @title = "Teammates"
    @debater = Debater.find(params[:id])
    debaters = Debater.teammates(@debater)
    
    if current_or_guest_debater == @debater
      debaters.each do |mate|
        mate.sign_in_count = -1 #Unique way to identify teammates
      end
      test = Array.new #Subtracting an empty array converts the result to an array
      @debaters = (debaters - test).paginate(:page => params[:page], :per_page => 15)
      render 'show_network_team'
    else
      @debaters = debaters.paginate(:page => params[:page], :per_page => 15)
      render 'show_network'
    end
  end
  
end
