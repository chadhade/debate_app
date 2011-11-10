class TrackingsController < ApplicationController
  def index
	# load all debates that this debater is tracking into @tracking_debates
	@debater = Debater.find(params[:debater_id])
	@tracking_debates = @debater.tracking_debates
	@currentdebater = current_debater
  end

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
