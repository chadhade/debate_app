class TrackingsController < ApplicationController
  def index
	# load all debates that this debater is tracking into @tracking_debates
	@debater = Debater.find(params[:debater_id])
	@tracking_debates = @debater.tracking_debates
	@currentdebater = current_debater
	
	# for viewings
	update_viewings(@currentdebater, @tracking_debates)	
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
	  viewer.viewings.create(:debate_id => debate.id, :currently_viewing => true)
	else
	  existing_viewing.each {|viewing| viewing.update_attributes(:currently_viewing => true)} # unless existing_viewing.currently_viewing == true
	end    
  end
##############################################################################  

  def new
  end

  def create
	@debate_id = params[:debate_id]
	current_debater.trackings.create(:debate_id => @debate_id)
    respond_to do |format|
	  format.html
	  format.js {render :nothing => true}
	end
  end

  def destroy
  end

end
