class VotesController < ApplicationController
  before_filter :authenticate_debater!
  
  def create
	  @argument = Argument.find_by_id(params[:argument_id])
	  @vote = params[:vote]
	  @debate_id = params[:debate_id]
	  @debate = Debate.find_by_id(@debate_id)
	  
	  @votee = Debater.find_by_id(@argument.debater_id)
	  
	  if @vote == "true"
	    current_debater.vote(@argument, :direction => :up)
	    upvotes = @votee.arg_upvotes
	    @votee.update_attributes(:arg_upvotes => upvotes + 1)
	  else
	    current_debater.vote(@argument, :direction => :down)
	    downvotes = @votee.arg_downvotes
	    @votee.update_attributes(:arg_downvotes => downvotes + 1)
    end
  
	  if current_debater.id != @debate.judge_id
	    Juggernaut.publish("debate_" + @debate_id + "_votes", {:func => "viewer_votes", :obj => {:id => params[:argument_id], :type => @vote}})
	  else
	    Juggernaut.publish("debate_" + @debate_id + "_judge", {:func => "judge_votes", :obj => {:votes => {:id => params[:argument_id], :type => @vote}}})
	  end
	  
	  respond_to do |format|
	    format.html
	    format.js {render :nothing => true}
	  end	
  end

  def topicvote
    
    debate = Debate.find_by_id(params[:topic_id])
    unless debate.nil?
      topic = Suggested_Topic.find_by_topicd(debate.topic.downcase)
      if topic.nil?
        topic = Suggested_Topic.new(:topic => debate.topic, :topicd => debate.topic.downcase, :rating => 1)
        topic.save
        current_debater.vote(topic, :direction => :up)
      else
        unless topic.updated_at > (Time.now - 5.seconds)
          newrating = topic.rating + 0.005
          topic.update_attributes(:rating => newrating) 
          current_debater.vote(topic, :direction => :up)
        end
      end
      
    end
    
    respond_to do |format|
	    format.html {render :nothing => true}
	    format.js
	  end
  end
end
