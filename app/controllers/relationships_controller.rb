class RelationshipsController < ApplicationController
  # before_filter :authenticate
  
  def create
    @debater = Debater.find(params[:relationship][:followed_id])
    current_debater.follow!(@debater)
    respond_to do |format|
      format.html { redirect_to @debater }
      format.js
    end
  end
  
  def destroy
    @debater = Relationship.find(params[:id]).followed
    current_debater.unfollow!(@debater)
    respond_to do |format|
      format.html {redirect_to @debater}
      format.js
    end
  end
  
end
