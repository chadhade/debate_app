class TopicPositionsController < ApplicationController
  before_filter :authenticate_debater!
  
  def create
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => params[:argument][:topic_position_topic], :position => params[:argument][:topic_position_position])
    @topic_position.save
    
    redirect_to :controller => "debates", :action => 'create', :argument => {:content => params[:argument][:content], :topic_position_id => @topic_position.id}
  end
  
  def matches
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => params[:topic_position][:topic], :position => params[:topic_position][:position])    
    @matching = Debate.matching_debates(@topic_position)
	  
    respond_to do |format|
  	  format.html
  	  format.js 
  	end
  end
  
  def index
    @matching = nil
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => "...", :position => true)
  end
  
  def new
  end

  def destroy
  end


  ############ allow double rendering ###################
  def reset_invocation_response
    self.instance_variable_set(:@_response_body, nil)
  end
  #######################################################

end
