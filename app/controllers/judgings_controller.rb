class JudgingsController < ApplicationController
  def index
    @judging_priority = Debate.judging_priority(10)
  end

  def create
    @debate = Debate.find(params[:debate_id])
    @judge = Judging.new(:debater_id => current_debater, :debate_id => @debate.id)
    @judge.save
    
    # remove debate from judging index page
    Juggernaut.publish("judging_index", {:remove => {:debate_id => @debate.id}})
	  reset_invocation_response # allow double rendering
    
    redirect_to @debate
  end
  
  ############ allow double rendering ###################
  def reset_invocation_response
    self.instance_variable_set(:@_response_body, nil)
  end
  #######################################################
end
