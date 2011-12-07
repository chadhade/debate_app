class TopicPositionsController < ApplicationController
  def create
    @topic_position = TopicPosition.new(:debater_id => current_debater, :topic => params[:topic_position][:topic], :position => params[:topic_position][:position])
  	@topic_position.save
  	redirect_to :action => 'matches'
  end

  def destroy
  end

  def matches
  end

end
