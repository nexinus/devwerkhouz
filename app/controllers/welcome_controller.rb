class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def show
    # Simple welcome page explaining Save & reuse etc.
    # Create a view at app/views/welcome/show.html.erb
  end

  # POST /welcome/complete
  def complete
    current_user.update(seen_welcome: true)
    # If the user had a stored return_to, use it and delete it
    return_to = session.delete(:return_to)
    if return_to.present? && return_to.start_with?('/')
      redirect_to return_to, notice: "You're all set — welcome!"
    else
      redirect_to after_sign_in_path_for(current_user), notice: "You're all set — welcome!"
    end
  end
end
