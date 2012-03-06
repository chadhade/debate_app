class DebatersController < ApplicationController
   before_filter :authenticate_debater!
   skip_before_filter :authenticate_debater! #, :only => [:show, :index]

   require 'will_paginate/array'
   
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
    
    #Cannot view profile page of guests
    if !@debater.last_sign_in_at 
      redirect_to topic_positions_path
    end
    
    # Individual Status
      if Rails.env.development? or Rails.env.test?
        @debates = @debater.debates.where("end_time > ?", 0)
      else
        @debates = @debater.debates.where("end_time > ?", "01/01/01")
      end
    
      @recentdebates = @debates.all(:order => "created_at DESC")
      @recentdebates = @recentdebates.paginate(:page => params[:page], :per_page => 10)
      
      @debateswon = Judging.where("winner_id = ?", @debater.id).count
      @debateslost = Judging.where("loser_id = ?", @debater.id).count
      @debatesnoresults = @debates.count - (@debateswon + @debateslost)
      @debaterjudgings = Judging.where("debater_id = ? AND winner_id > ?", @debater.id, 0).count  
      
      argument_ids = @debater.arguments.collect{|u| u.id}
      @positivevotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ?", argument_ids, "Argument", true).count
      @negativevotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ?", argument_ids, "Argument", false).count
      
    # Team Stats
      @teammates = Debater.teammates(@debater)
      
      if !@teammates.empty? # Only perform calculations if debater has teammates
        @teammates << @debater
        teamargument_ids = Array.new
      
        if Rails.env.development? or Rails.env.test?
          @teamdebates = 0
          @teamjudgepoints = 0
          @teammates.each do |deb|
            @teamdebates += deb.debates.where("end_time > ?", 0).count
            @teamjudgepoints += deb.judge_points
            teamargument_ids =  teamargument_ids + deb.arguments.collect{|u| u.id}
          end
        else
          @teamdebates = Array.new
          @teamjudgepoints = 0
          @teammates.each do |deb|
            @teamdebates << deb.debates.where("end_time > ?", "01/01/01")
            @teamjudgepoints += deb.judge_points
            teamargument_ids = teamargument_ids + deb.arguments.collect{|u| u.id}
          end
        end
        
        team_ids = @teammates.collect{|u| u.id}
      
        @teamdebateswon = Judging.where("winner_id IN (?)", team_ids).count
        @teamdebateslost = Judging.where("loser_id IN (?)", team_ids).count
        @teamdebatesnoresults = @teamdebates.count - (@teamdebateswon + @teamdebateslost)
        @teamjudgings = Judging.where("debater_id IN (?) AND winner_id > ?", team_ids, 0).count
      
        @teampositivevotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ?", teamargument_ids, "Argument", true).count
        @teamnegativevotes = Vote.where("voteable_id IN (?) AND voteable_type = ? AND vote = ?", teamargument_ids, "Argument", false).count
      
      end
      
      follow_ids = Array.new
      @following = @debater.following
      @following.empty? ? return : nil # Exit if there are no 'followees'
      
      @following.each do |debater|
        debater.debates.all(:order => "id DESC").first(20).each do |debate|
          follow_ids << debate.id
        end
      end
      @followdebates = Debate.where("id IN (?)", follow_ids).last(30)
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
    debaters = Debater.where("current_sign_in_at > ?", "01/01/01")
    @debaterranks = Array.new
    
    if !debaters.empty?
      debaters.each do |debater|
        rank = debater.rank
        @debaterranks << {:debater => debater, :rank => rank, :joined => debater.created_at}
      end
      @debaterranks.sort!{|a,b| b[:rank] <=> a[:rank]}
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
      test = Array.new #Subtracting this array converts the result to an array
      @debaters = (debaters - test).paginate(:page => params[:page], :per_page => 15)
      render 'show_network_team'
    else
      @debaters = debaters.paginate(:page => params[:page], :per_page => 15)
      render 'show_network'
    end
  end
  
end
