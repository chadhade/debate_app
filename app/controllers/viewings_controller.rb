class ViewingsController < ApplicationController
  def leaving_page
    respond_to do |format|
	  format.html
	  format.js {render :nothing => true}
	end
  end

end
