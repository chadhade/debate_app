class TopicPositionsController < ApplicationController
  before_filter :authenticate_debater!
  
  def create
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => params[:topic_position][:topic], :position => params[:topic_position][:position])
  	@topic_position.save
  	redirect_to matches_topic_position_path(@topic_position)
    
    #@matching = Debate.matching_debates(@topic_position)
	  
    #respond_to do |format|
  	  #format.html
  	  #format.js 
  	#end
  end
  
  def index
    
  end
  
  def new
  end

  def destroy
  end

  def matches
    @topic_position = TopicPosition.find(params[:id])
    @matching = Debate.matching_debates(@topic_position)
    
  end

  ############ allow double rendering ###################
  def reset_invocation_response
    self.instance_variable_set(:@_response_body, nil)
  end
  #######################################################

end
