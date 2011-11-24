class Debaters::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @debater = Debater.find_for_facebook_oauth(request.env["omniauth.auth"], current_debater)

    if @debater.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @debater, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_debater_registration_url
    end
  end
end