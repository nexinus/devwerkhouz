class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user, :user_signed_in?

  protected

  # Central post-login landing page. Edit here to change where users go after sign-in.
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  private

  def current_user
    return @current_user if defined?(@current_user)
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    end
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    return if user_signed_in?

    # store location so we can return after login (safe: only store internal paths)
    if request.get? && request.fullpath.present?
      session[:return_to] = request.fullpath if request.fullpath.start_with?('/')
    end

    redirect_to login_path, alert: "Please sign in to continue."
  end
end
