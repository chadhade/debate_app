class ViewingsController < ApplicationController
  def leaving_page
    @currentdebater = current_or_guest_debater

  	if !params[:debate_id].nil?
  	  @debate = Debate.find(params[:debate_id])
  	  @is_creator = @debate.creator?(@currentdebater)
  	  @is_joiner = @debate.joiner?(@currentdebater)
  	  @is_judger = @debate.judger?(@currentdebater)
  	  update_viewings(@currentdebater, @debate, @is_creator) unless @debate.end_time
  	  
  	  if !@currentdebater.nil? and (@is_creator or @is_joiner or @is_judger)
  	    if @is_creator and !@debate.joined?
    	    Juggernaut.publish("matches", {:func => "hide", :obj => @debate.id})
      	  reset_invocation_response # allow double rendering
          # Juggernaut.publish("judging_index", {:function => "remove", :debate_id => @debate.id})
    	  end
        # if @currentdebater.judge?(@debate) and !@debate.joined?
        #   Judging.destroy(@debate.judge.id)
        #   Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_exists", :obj => {:who_code => "judge", :who_value => ""}})
        #   @debate.update_attributes(:judge => false)
        #   debate_link_unjoined = render(:partial => "/judgings/debate_link_unjoined", :locals => {:debate => @debate}, :layout => false)
        #   Juggernaut.publish("judging_index", {:function => "add_to_unjoined", :debate_id => @debate.id, :object => debate_link_unjoined})
        #   reset_invocation_response # allow double rendering
        # end
    	  #update currently viewing status if creator, joiner or judge
    	  Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater1", :who_value => "false", :who_message => "#{@currentdebater.mini_name} has left."}}) if @is_creator
      	Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater2", :who_value => "false", :who_message => "#{@currentdebater.mini_name} has left."}}) if @is_joiner
      	Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "judge", :who_value => "false", :who_message => "Judge has left the debate page.\n"}}) if @is_judger
      	#update judgings index if either the creator or joiner is leaving
      	Juggernaut.publish("judging_index", {:function => "hide_joined", :debate_id => @debate.id}) if @is_creator or @is_joiner
    	end
    	
  	else
  	  #update_viewings(@currentdebater, @currentdebater.tracking_debates, @is_creator, @is_joiner)
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
  
##############################################################################  
  def update_viewings(currentdebater, debates, is_creator)
	# set viewer variable
	viewer = currentdebater
	
	# go through debates and update viewings for viewer and debate
	if debates.kind_of?(Array)
	  debates.each {|debate| update_viewings_for_viewer_debate(viewer, debate, is_creator)}
	else
	  update_viewings_for_viewer_debate(viewer, debates, is_creator)
	end	
  end
  
  def update_viewings_for_viewer_debate(viewer, debate, creator)
  	#existing_viewing = viewer.viewings.where("debate_id = ?", debate.id)
  	existing_viewing = debate.viewings.where("viewer_id = ?", viewer.id)
  	if existing_viewing.any?
  	  #debate.viewings.create(:viewer_id => viewer.id, :currently_viewing => false, :creator => creator, :joiner => joiner)
  	  existing_viewing.each do |viewing|
  	    viewing.destroy
  	  end
  	end
  end
##############################################################################  

end
