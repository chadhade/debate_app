 class TopicPositionsController < ApplicationController
  before_filter :authenticate_debater!
  
  def create
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => params[:argument][:topic_position_topic], :position => params[:argument][:topic_position_position])
    @topic_position.save
    
    redirect_to :controller => "debates", :action => 'create', :argument => {:content => params[:argument][:content], :topic_position_id => @topic_position.id}
  end
  
  def matches
    params[:topic2] ? topic = params[:topic_position][:topic] + " vs " + params[:topic2] : topic = params[:topic_position][:topic]
    if params[:topic_position][:position] == "vs" or  params[:topic_position][:position] == nil
      position = nil
    else
      position = params[:topic_position][:position]
    end
    
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => topic, :position => position)    
    @matching = Debate.matching_debates(@topic_position)
	  
    respond_to do |format|
  	  format.html
  	  format.js 
  	end
  end
  
  def index
    @matching = nil
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => "...", :position => nil)
    @trending = Suggested_Topic.trending(10)
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
