class ViewingsController < ApplicationController
  def leaving_page
    @currentdebater = current_debater

  	if !params[:debate_id].nil?
  	  @debate = Debate.find(params[:debate_id])
  	  update_viewings(@currentdebater, @debate)
  	  
  	  if !@currentdebater.nil?
  	    if @currentdebater.creator?(@debate) and !@debate.joined?
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
    	  Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater1", :who_value => "false"}}) if @currentdebater.creator?(@debate)
      	Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "debater2", :who_value => "false"}}) if @currentdebater.joiner?(@debate)
      	Juggernaut.publish("debate_" + @debate.id.to_s, {:func => "update_individual_cv", :obj => {:who_code => "judge", :who_value => "false"}}) if @currentdebater.judge?(@debate)
      	#update judgings index if either the creator or joiner is leaving
      	Juggernaut.publish("judging_index", {:function => "hide_joined", :debate_id => @debate.id}) if @debate.creator?(@currentdebater) or @debate.joiner?(@currentdebater)
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
  	  joiner = viewer.class.name == 'Debater' ? debate.joiner?(viewer) : false
  	  viewer.viewings.create(:debate_id => debate.id, :currently_viewing => false, :creator => creator, :joiner => joiner)
  	else
  	  existing_viewing.each do |viewing| 
  	    viewing.update_attributes(:currently_viewing => false) # unless existing_viewing.currently_viewing == true
  	    if viewer.class.name == 'Debater'
  	      viewing.update_attributes(:joiner => true) if viewing.debate.joiner?(viewer)
	      end
	    end
  	end    
  end
##############################################################################  

end
