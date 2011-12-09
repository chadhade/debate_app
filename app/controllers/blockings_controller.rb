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

  def borrow
    @blocker = Debater.find(params[:blocking][:blocker_id])
    @blocker_id = params[:blocking][:blocker_id]
    
    blocked_ids = Blocking.where("blocker_id = ?", @blocker_id).map{|v| v.blocked_id}
    already_blocked_ids = Blocking.where("blocker_id = ?", current_debater.id).map{|v| v.blocked_id}
    blocked_differences = blocked_ids - already_blocked_ids
    
    blocked_differences.each do |blocked|
      current_debater.blockings.create!(:blocked_id => blocked)
    end
    respond_to do |format|
      format.html {redirect_to @blocker}
      format.js
    end

  end
  
end
