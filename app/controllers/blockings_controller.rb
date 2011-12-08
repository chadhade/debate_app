class BlockingsController < ApplicationController
  # before_filter :authenticate
  
  def create
    @debater = Debater.find(params[:blocking][:blocked_id])
    current_debater.block!(@debater)
    respond_to do |format|
      format.html {redirect_to @debater}
      format.js
    end
  end
  
  def destroy
    @debater = Blocking.find(params[:id]).blocked
    current_debater.unblock!(@debater)
    respond_to do |format|
      format.html {redirect_to @debater}
      format.js
    end
  end

end
