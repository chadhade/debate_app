class JudgingsController < ApplicationController
  before_filter :authenticate_debater!
  skip_before_filter :authenticate_debater!, :only => [:rating]
  
  require 'will_paginate/array'
  
  def index
    currentdebater = current_or_guest_debater
    blocker_ids = currentdebater.blockers.map(&:id) + [0]
    
    judging_priority = Debate.judging_priority(30, blocker_ids)
    if !judging_priority.empty?
      @joined_no_judge = judging_priority.paginate(:page => params[:page], :per_page => 15)
    end
    
    respond_to do |format|
        format.html 
        format.js
      end
  end

  def create
    @debate = Debate.find(params[:debate_id])
    @currentdebater = current_or_guest_debater
    
    if !(@currentdebater.waiting_for != nil or @debate.creator.is_blocking?(@currentdebater.id))
      if !@debate.creator?(@currentdebater) and !@debate.joiner?(@currentdebater) and !@debate.judge
        @judge = Judging.new(:debater_id => @currentdebater.id, :debate_id => @debate.id)
        @judge.save
        @debate.update_attributes(:judge => true, :judge_id => @currentdebater.id, :started_at => Time.now)
    	
      	@debatestatus = @debate.status
    	
        # If judge joined after both debaters joined, add time spent waiting for judge back to debater 1's time bank
        # Then start timers
        @arguments = @debate.arguments.all(:order => "created_at ASC")
        if @debate.joined
          @firstarg = @arguments.first
          @secondarg = @arguments.second
          @oldtime = @firstarg.time_left
          @timeleft = @oldtime + (Time.now - @judge.created_at).seconds.to_i
          #@firstarg.update_attributes(:time_left => @timeleft)
          @currentturn = @firstarg.debater.name
 
          Juggernaut.publish("debate_" + params[:debate_id], {:func => "start_debate", :obj => {:timers => {:movingclock => @oldtime, :staticclock => @secondarg.time_left, :movingposition => 1, 
                            :debateid => params[:debate_id]}, :current_turn => @currentturn}})
        end
        # remove debate from judging index page
        Juggernaut.publish("judging_index", {:function => "remove", :debate_id => @debate.id})
        # update status bar on show page
        Juggernaut.publish("debate_" + params[:debate_id], {:func => "update_status", :obj => @debatestatus})
        # update individual status
        Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_exists", :obj => {:who_code => "judge", :who_value => "Judge"}})
        # Publish to waiting channel
        Juggernaut.publish("waiting_channel", {:func => "debate_update", :obj => {:debate => @debate.id, :status_value => @debatestatus[:status_value], :status_code => @debatestatus[:status_code]}})
      
        redirect_to @debate
      else
        redirect_to :controller => "judgings", :action => "index"
      end
    else
      redirect_to :controller => "judgings", :action => "index"
    end
  end
  
  def submission
    @judging = Judging.find(params[:id])
    @judgeid = @judging.debater_id
    
    @debate = @judging.debate
    
    #Make sure it is submitted at the proper time and only once
    if @debate.end_time and !@debate.winner_id and !params[:judging][:winner_id].nil?
      if Time.now < @debate.end_time + $judgetime
        
        winner_id = params[:judging][:winner_id].to_i
        case winner_id
        when @debate.creator_id
          loser_id = @debate.joiner_id
        when @debate.joiner_id
          loser_id = @debate.creator_id
        when 0
          loser_id = nil
        end
        @judging.update_attributes(:winner_id => winner_id, :comments => params[:judging][:comments], :loser_id => loser_id)
      
        @debate.update_attributes(:winner_id => winner_id, :loser_id => loser_id)
        @debate.save
      
        #tally up judge's votes
        @votes = Array.new
        upvotes = 0
        downvotes = 0
      
        @debate.arguments.each do |argument|
          votes_for = argument.votes_for_by(@judgeid)
          votes_against = argument.votes_against_by(@judgeid)
          @votes[argument.id] = votes_for - votes_against
          upvotes = upvotes + votes_for
          downvotes = downvotes + votes_against
        end
      
        #Adjust Debater Ratings
        d1 = @debate.creator
        d2 = @debate.joiner
        rating_adjust = false
        if !(d1.guest? or d2.guest?)
          rating_change = true
          d1_old = d1.rating
          d2_old = d2.rating
          if winner_id == 0
            result = 0.5
          else
            winner_id == @debate.creator_id ? result = 1 : result = 0
          end
          judge = @debate.judger
          new_ratings = d1.rating_adjust(d2, result, judge.rating)
        else
          new_ratings = [d1_old, d2_old]
        end
        
        judging_results = render(:partial => "/judgings/judging_results", :layout => false, :locals => {:judging => @judging, :upvotes => upvotes, :downvotes => downvotes, :creator => d1, :joiner => d2})
        reset_invocation_response # allow double rendering
      
        # Show Judge Rating form on status bar
        ratings_form_render = render(:partial => "judgings/rate_judge", :layout => false, :locals => {:judging => @judging, :debateid => @debate.id})
      
        reset_invocation_response # allow double rendering
        Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "judge_results", :obj => {:judging_results => judging_results, :judge_votes => @votes, :judgeid => @judgeid, :ratings_form => ratings_form_render, 
                            :winner_id => winner_id == 0 ? @debate.creator_id : winner_id, :loser_id => winner_id == 0 ? @debate.joiner_id : loser_id, :rating_change => rating_change, 
                            :d1_old => d1_old, :d2_old => d2_old, :d1 => new_ratings[0], :d2 => new_ratings[1], :joiner_id => @debate.joiner_id}})
        reset_invocation_response # allow double rendering
        Juggernaut.publish("debate_" + @debate.id.to_s + "_judge", {:judging_form => "clear_form"})
    
        # Signal that debate has ended
 
        Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "end_debate", :obj => {:joiner_id => @debate.joiner_id}})
      
      end
    end
    
    # update status bar on show page
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_status", :obj => @debate.status})
    Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "judge_timer_remove"})
    
    respond_to do |format|
  	  format.html
  	  format.js {render :nothing => true}
  	end
  end
  
  def rating
    @judging = Judging.find_by_id(params[:judging][:judging_id])
    @debate = Debate.find(params[:judging][:debate_id])
    @currentdebater = current_or_guest_debater
    
    unless @judging.winner_approve
      if @currentdebater.id == @judging.winner_id or (@judging.winner_id == 0 and @currentdebater.id == @debate.creator_id)
        @judging.update_attributes(:winner_approve => params[:judging][:winner_approve])
        @judging.save
        if params[:judging][:winner_approve] == "true" and @judging.loser_approve
          debater = Debater.find_by_id(@judging.debater_id)
          debater.update_attributes(:judge_points => debater.judge_points + 1)
          debater.save
        end
      end
    end
    
    unless @judging.loser_approve
      if @currentdebater.id == @judging.loser_id or (@judging.winner_id == 0 and @currentdebater.id == @debate.joiner_id)
        @judging.update_attributes(:loser_approve => params[:judging][:winner_approve])
        @judging.save
        if params[:judging][:winner_approve] == "true" and @judging.winner_approve
          debater = Debater.find_by_id(@judging.debater_id)
          debater.update_attributes(:judge_points => debater.judge_points + 1)
          debater.save
        end
      end
    end
    
    # update status bar on show page
    ratings_render = render(:partial => "judgings/debater_ratings", :locals => {:judging => @judging, :debate => @debate}, :layout => false)
    reset_invocation_response # allow double rendering
    Juggernaut.publish("debate_" + params[:judging][:debate_id], {:func => "debater_ratings", :obj => {:ratings => ratings_render, :rater_id => @currentdebater.id}})
    
    respond_to do |format|
  	  format.html
  	  format.js {render :nothing => true}
  	end  
  end
  
  ############ allow double rendering ###################
  def reset_invocation_response
    self.instance_variable_set(:@_response_body, nil)
  end
  #######################################################
end
