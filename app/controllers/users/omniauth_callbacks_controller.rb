class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env['omniauth.auth']
    @user = User.from_omniauth(auth)

    if @user.persisted?
      # Set seen_welcome if first login (optional enhancement)
      unless @user.seen_welcome?
        @user.update(seen_welcome: true)
      end

      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      # store data for sign up form if you want to finish registration
      session["devise.google_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  rescue StandardError => e
    Rails.logger.error "Google OAuth error: #{e.message}"
    redirect_to new_user_session_path, alert: "Authentication failed. Please try again."
  end

  def failure
    reason = request.params[:message] || "unknown error"
    Rails.logger.error "OmniAuth failure: #{reason}"
    redirect_to new_user_session_path, alert: "Google sign-in was cancelled or failed. Please try again."
  end
end
  