class TopicPositionsController < ApplicationController
  before_filter :authenticate_debater!
  
  def create
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => params[:topic_position][:topic], :position => params[:topic_position][:position])
  	@topic_position.save
  	redirect_to matches_topic_position_path(@topic_position)
  end

  def destroy
  end

  def matches
    @topic_position = TopicPosition.find(params[:id])
    @matching_debates = Debate.matching_debates(@topic_position)
  end

end
