class Debaters::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @debater = Debater.find_for_facebook_oauth(request.env["omniauth.auth"], current_debater)

    if @debater.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @debater, :event => :authentication
    else
      #session["devise.facebook_data"] = request.env["omniauth.auth"]
      if @debater.save
        sign_in_and_redirect @debater, :event => :authentication
      else
        errorarray = Array.new
        @debater.errors.full_messages.each do |error|
          errorarray << "Could not authorize you from Facebook because #{error}."
        end
        flash[:alert] = errorarray.join("<br/>").html_safe
        redirect_to new_debater_registration_url(:name => @debater.name, :email => @debater.email)
      end
    end
  end

  def twitter
      # You need to implement the method below in your model
      @debater = Debater.find_for_twitter_oauth(request.env["omniauth.auth"], current_debater)

      if @debater.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
        sign_in_and_redirect @debater, :event => :authentication
      else
        #session["devise.twitter_data"] = request.env["omniauth.auth"]
        if @debater.save
          sign_in_and_redirect @debater, :event => :authentication
        else
          errorarray = Array.new
          @debater.errors.full_messages.each do |error|
            errorarray << "Could not authorize you from Twitter because #{error}."
          end
          flash[:alert] = errorarray.join("<br/>").html_safe
          redirect_to new_debater_registration_url(:name => @debater.name)
        end
      end
    end
end