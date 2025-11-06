class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # OmniAuth uses its own state param for CSRF protection; skip Rails CSRF for the callback
  skip_before_action :verify_authenticity_token, only: [:google_oauth2, :failure], raise: false

  def google_oauth2
    auth = request.env['omniauth.auth']

    unless auth&.info&.email.present?
      redirect_to new_user_session_path, alert: "No auth data received from Google." and return
    end

    # Centralized creation / update logic in the model
    @user = User.from_omniauth(auth)

    unless @user
      redirect_to new_user_session_path, alert: "Could not authenticate via Google." and return
    end

    # Double-check avatar_url persisted (from_omniauth already writes it when needed);
    # this ensures provider image is stored if present and different.
    if auth.info.image.present?
      provider_image = auth.info.image.to_s
      if @user.avatar_url != provider_image
        # try a non-validating write to avoid blocking due to any validation rules
        begin
          @user.update_columns(avatar_url: provider_image)
        rescue StandardError
          @user.update(avatar_url: provider_image) rescue nil
        end
      end
    end

    if @user.persisted?
      # mark welcome seen for new OAuth users (optional)
      if @user.respond_to?(:seen_welcome) && @user.seen_welcome.blank?
        @user.update(seen_welcome: true)
      end

      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.google_data"] = auth.except("extra")
      redirect_to new_user_registration_url, alert: "Could not create or sign in the user."
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Google sign-in failed"
  end
end
