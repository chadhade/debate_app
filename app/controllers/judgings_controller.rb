class JudgingsController < ApplicationController
  def index
    @judging_priority = Debate.judging_priority()
  end

  def create
    @debate = Debate.find(params[:debate_id])
    @judge = Judging.new(:debater_id => current_debater.id, :debate_id => @debate.id)
    @judge.save
    @debate.update_attributes(:judge => true)
    
    # remove debate from judging index page
    Juggernaut.publish("judging_index", {:function => "remove", :debate_id => @debate.id})
    
    redirect_to @debate
  end
  
  def submission
    @judging = Judging.find(params[:id])
    @judging.update_attributes(:winner_id => params[:judging][:winner_id], :comments => params[:judging][:comments])
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
