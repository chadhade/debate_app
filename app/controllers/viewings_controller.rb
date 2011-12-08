class ViewingsController < ApplicationController
  def leaving_page
    @currentdebater = current_debater

  	if !params[:debate_id].nil?
  	  @debate = Debate.find(params[:debate_id])
  	  update_viewings(@currentdebater, @debate)
  	  if @currentdebater.creator?(@debate) and !@debate.joined?
  	    Juggernaut.publish("matches", {:debate_id => @debate.id})
    	  reset_invocation_response # allow double rendering
    	  Juggernaut.publish("judging_index", {:remove => {:debate_id => @debate.id}})
    	  reset_invocation_response # allow double rendering
  	  end
  	  if @currentdebater.judge?(@debate) and !@debate.joined?
  	    Judging.destroy(@debate.judge.id)
  	    @debate.update_attributes(:judge => false)
  	    Juggernaut.publish("judging_index", {:add => {:debate_id => @debate.id}})
    	  reset_invocation_response # allow double rendering
  	  end
  	else
  	  update_viewings(@currentdebater, @currentdebater.tracking_debates)
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
  def update_viewings(currentdebater, debates)
	# set viewer variable
	if currentdebater.nil?
	  ip = Ip.new(:IP_address => request.remote_ip)
      ip = Ip.find_by_IP_address(request.remote_ip) unless ip.save
      viewer = ip
	else
	  viewer = currentdebater
	end
	# go through debates and update viewings for viewer and debate
	if debates.kind_of?(Array)
	  debates.each {|debate| update_viewings_for_viewer_debate(viewer, debate)}
	else
	  update_viewings_for_viewer_debate(viewer, debates)
	end	
  end
  
  def update_viewings_for_viewer_debate(viewer, debate)
  	existing_viewing = viewer.viewings.where("debate_id = ?", debate.id)
  	if existing_viewing.empty?
  	  creator = viewer.class.name == 'Debater' ? debate.creator?(viewer) : false
  	  viewer.viewings.create(:debate_id => debate.id, :currently_viewing => true, :creator => creator)
  	else
  	  existing_viewing.each {|viewing| viewing.update_attributes(:currently_viewing => true)} # unless existing_viewing.currently_viewing == true
  	end    
  end
##############################################################################  

end
