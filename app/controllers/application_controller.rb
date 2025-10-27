class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # If Devise is present it will provide `current_user` and `user_signed_in?` helpers.
  # Do NOT redefine `current_user` when using Devise (that would override Devise's helper).
  # We only expose the Devise hooks for permitting parameters.
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Central post-login landing page. Edit here to change where users go after sign-in.
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboard_path
  end

  # Permit extra attributes through Devise strong-params.
  # Add any additional keys (e.g. :first_name, :last_name) you need for sign_up / account_update.
  def configure_permitted_parameters
    # Example: permit :name and :username on sign up and account update
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :first_name, :last_name, :username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :first_name, :last_name, :username])
  end

  private

  # Wrap authentication behavior so this controller works both while you're migrating
  # and after Devise is fully wired. If Devise is installed, call its `authenticate_user!`.
  # Otherwise, fall back to your old session-based redirect.
  def authenticate_user!
    # If Devise is loaded, call Devise's authenticate_user! (it will redirect as needed).
    if defined?(Devise)
      # store location for Devise after sign in if this is a safe GET to an internal path
      if request.get? && request.fullpath.present? && request.fullpath.start_with?('/') && respond_to?(:store_location_for)
        store_location_for(:user, request.fullpath)
      end

      # call Devise's own authenticate_user!
      super
    else
      # fallback to original session-based auth while migrating
      return if user_signed_in_fallback?

      if request.get? && request.fullpath.present?
        session[:return_to] = request.fullpath if request.fullpath.start_with?('/')
      end

      redirect_to login_path, alert: "Please sign in to continue."
    end
  end

  # Fallback user_signed_in? that checks your old session[:user_id] while Devise isn't present.
  # This is intentionally a private helper so it doesn't conflict with Devise's public `user_signed_in?`.
  def user_signed_in_fallback?
    # If Devise provides user_signed_in?, prefer it.
    return user_signed_in if respond_to?(:user_signed_in) && defined?(Devise)

    # Otherwise fallback to session-based logic (the original behavior)
    session[:user_id].present?
  end
end
