# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Skip CSRF verification - OmniAuth validates via state parameter
  skip_before_action :verify_authenticity_token, only: [:google_oauth2, :failure], raise: false

  def google_oauth2
    auth = request.env['omniauth.auth']
    unless auth
      redirect_to new_user_session_path, alert: "No auth data received."
      return
    end

    @user = User.where(provider: auth.provider, uid: auth.uid).first
    @user ||= User.find_by(email: auth.info.email)
    @user ||= User.from_omniauth(auth) # creates and saves user if needed

    if @user.persisted?
      # optional: mark welcome seen on first sign-in
      @user.update(seen_welcome: true) if @user.respond_to?(:seen_welcome) && @user.seen_welcome.blank?

      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.google_data"] = auth.except("extra")
      redirect_to new_user_registration_url, alert: "Could not authenticate via Google."
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Google sign-in failed"
  end
end
