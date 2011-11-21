class ViewingsController < ApplicationController
  def leaving_page
    @currentdebater = current_debater

	if !params[:debate_id].nil?
	  update_viewings(@currentdebater, Debate.find(params[:debate_id]))
	else
	  update_viewings(@currentdebater, @currentdebater.tracking_debates)
	end
    
	respond_to do |format|
	  format.html
	  format.js {render :nothing => true}
	end
  end
  
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
	  viewer.viewings.create(:debate_id => debate.id, :currently_viewing => false)
	else
	  existing_viewing.each {|viewing| viewing.update_attributes(:currently_viewing => false)} # unless existing_viewing.currently_viewing == true
	end    
  end
##############################################################################  

end