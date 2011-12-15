class JudgingsController < ApplicationController
  def index
    @judging_priority = Debate.judging_priority()
  end

  def create
    @debate = Debate.find(params[:debate_id])
    @judge = Judging.new(:debater_id => current_debater.id, :debate_id => @debate.id)
    @judge.save
    @debate.update_attributes(:judge => true)
    
    # If judge joined after both debaters joined, add time spent waiting for judge back to debater 1's time bank
    # Then start timers
    if @debate.arguments.count == 2
      @firstarg = @debate.arguments.first
      @secondarg = @debate.arguments[1]
      @oldtime = @firstarg.time_left
      @timeleft = @oldtime + (@judge.created_at - @secondarg.created_at).seconds.to_i
      @firstarg.update_attributes(:time_left => @timeleft)
      
      Juggernaut.publish("debate_" + params[:debate_id], {:timers => {:movingclock => @oldtime, :staticclock => @secondarg.time_left, :movingposition => 1, 
                        :debateid => params[:debate_id]}, :argument => "", :judge => true})
    end
    
    # remove debate from judging index page
    Juggernaut.publish("judging_index", {:function => "remove", :debate_id => @debate.id})
    
    redirect_to @debate
  end
  
  def submission
    @judging = Judging.find(params[:id])
    @debate = @judging.debate
    
    if Time.now < @debate.end_time + 20.seconds
      @judging.update_attributes(:winner_id => params[:judging][:winner_id], :comments => params[:judging][:comments])
      judging_results = render(:partial => "/judgings/judging_results", :layout => false, :locals => {:judging => @judging})
      Juggernaut.publish("debate_" + @debate.id.to_s, {:judging_results => judging_results})
      reset_invocation_response # allow double rendering
      Juggernaut.publish("debate_" + @debate.id.to_s + "_judge", {:judging_form => "clear_form"})
    end
    
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
