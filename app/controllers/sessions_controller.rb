class SessionsController < ApplicationController
  def new
  end

  def create
    @debater = Debater.find_by_name(params[:session][:name])
	sign_in @debater
	redirect_to debates_path
  end

  def destroy
    sign_out
	redirect_to new_session_path
  end

end
