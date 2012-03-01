class RelationshipsController < ApplicationController
  before_filter :authenticate_debater!
  
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
  
  def create_teammate
    currentid = current_debater.id
    relationship = Relationship.where("follower_id = ? AND followed_id = ?", currentid, params[:debater_id]).first
    unless relationship.nil?
      relationship.update_attributes(:teammate => true)
    end
    
    respond_to do |format|
      format.html {redirect_to following_debater_path(currentid)}
      format.js
    end
  end
  
  def remove_teammate
    currentid = current_debater.id
    relationship = Relationship.where("follower_id = ? AND followed_id = ?", currentid, params[:debater_id]).first
    unless relationship.nil?
      relationship.update_attributes(:teammate => false)
    end
    params[:page]=="Teammates" ? @path = teammates_debater_path(currentid) : @path = following_debater_path(currentid)
    
    respond_to do |format|
      format.html {redirect_to @path}
      format.js
    end
  end
end


