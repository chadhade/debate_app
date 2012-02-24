class JudgingsController < ApplicationController
  before_filter :authenticate_debater!
  skip_before_filter :authenticate_debater!, :only => [:rating]
  
  def index
    judging_priority = Debate.judging_priority(30)
    if !judging_priority.nil?
      @joined_no_judge = judging_priority.paginate(:page => params[:page], :per_page => 10)
    end
    
    respond_to do |format|
        format.html 
        format.js
      end
  end

  def create
    @debate = Debate.find(params[:debate_id])
    
    if !@debate.creator?(current_or_guest_debater) and !@debate.joiner?(current_or_guest_debater) and !@debate.judge
      @judge = Judging.new(:debater_id => current_or_guest_debater.id, :debate_id => @debate.id)
      @judge.save
      @debate.update_attributes(:judge => true)
      
      # if debater was currently waiting for another debate, he now stops waiting
    	if current_or_guest_debater.waiting_for
    	  current_or_guest_debater.update_attributes(:waiting_for => nil)
    	end
    	
      # If judge joined after both debaters joined, add time spent waiting for judge back to debater 1's time bank
      # Then start timers
      if @debate.arguments.count == 2
        @firstarg = @debate.arguments.first(:order => "created_at ASC")
        @secondarg = @debate.arguments.all(:order => "created_at ASC").second
        @oldtime = @firstarg.time_left
        @timeleft = @oldtime + (Time.now - @judge.created_at).seconds.to_i
        @firstarg.update_attributes(:time_left => @timeleft)
        @currentturn = @debate.arguments.first(:order => "created_at ASC").debater.email
 
        Juggernaut.publish("debate_" + params[:debate_id], {:func => "judge_arrived", :obj => {:timers => {:movingclock => @oldtime, :staticclock => @secondarg.time_left, :movingposition => 1, 
                          :debateid => params[:debate_id]}, :argument => "", :judge => true, :current_turn => @currentturn}})
      end
      # remove debate from judging index page
      Juggernaut.publish("judging_index", {:function => "remove", :debate_id => @debate.id})
      # update status bar on show page
      Juggernaut.publish("debate_" + params[:debate_id], {:func => "update_status", :obj => @debate.status})
      # update individual status
      Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_exists", :obj => {:who_code => "judge", :who_value => "Judge"}})
      # Publish to waiting channel
      Juggernaut.publish("waiting_channel", {:func => "debate_update", :obj => {:debate => @debate.id, :status_value => @debate.status[:status_value]}})
      
      redirect_to @debate
    else
      redirect_to :controller => "judgings", :action => "index"
    end
  end
  
  def submission
    @judging = Judging.find(params[:id])
    @judgeid = @judging.debater_id
    
    @debate = @judging.debate
    @debate.creator.id.to_s == params[:judging][:winner_id] ? @loser_id = @debate.joiner.id : @loser_id = @debate.creator.id
    

    if Time.now < @debate.end_time + $judgetime
      @judging.update_attributes(:winner_id => params[:judging][:winner_id], :comments => params[:judging][:comments], :loser_id => @loser_id)
      
      # Trying to move winner_id and loser_id to the debate table
      @debate.update_attributes(:winner_id => params[:judging][:winner_id], :loser_id => @loser_id)
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
      
      judging_results = render(:partial => "/judgings/judging_results", :layout => false, :locals => {:judging => @judging, :upvotes => upvotes, :downvotes => downvotes})
      reset_invocation_response # allow double rendering
      
      # Show Judge Rating form on status bar
      ratings_form_render = render(:partial => "judgings/rate_judge", :layout => false, :locals => {:judging => @judging, :debateid => @debate.id})
      
      reset_invocation_response # allow double rendering
      Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "judge_results", :obj => {:judging_results => judging_results, :judge_votes => @votes, :judgeid => @judgeid, :ratings_form => ratings_form_render, :winner_id => params[:judging][:winner_id].to_i, :loser_id => @loser_id}})
      reset_invocation_response # allow double rendering
      Juggernaut.publish("debate_" + @debate.id.to_s + "_judge", {:judging_form => "clear_form"})
    
      # Signal that debate has ended
 
      Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "end_debate", :obj => {:joiner_id => @debate.joiner.id}})
      
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
    
    if current_or_guest_debater.id == @judging.winner_id
      @judging.update_attributes(:winner_approve => params[:judging][:winner_approve])
      @judging.save
      if params[:judging][:winner_approve] == "true" and @judging.loser_approve
        debater = Debater.find_by_id(@judging.debater_id)
        debater.update_attributes(:judge_points => debater.judge_points + 1)
        debater.save
      end
    end
    
    if current_or_guest_debater.id == @judging.loser_id
      @judging.update_attributes(:loser_approve => params[:judging][:winner_approve])
      @judging.save
      if params[:judging][:winner_approve] == "true" and @judging.winner_approve
        debater = Debater.find_by_id(@judging.debater_id)
        debater.update_attributes(:judge_points => debater.judge_points + 1)
        debater.save
      end
    end
    
    # update status bar on show page
    ratings_render = render(:partial => "judgings/debater_ratings", :locals => {:judging => @judging}, :layout => false)
    reset_invocation_response # allow double rendering
    Juggernaut.publish("debate_" + params[:judging][:debate_id], {:func => "debater_ratings", :obj => {:ratings => ratings_render}})
    
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
