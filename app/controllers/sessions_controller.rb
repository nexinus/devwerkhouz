class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      # If user already saw the welcome, honor stored return_to (if present) or default
      if user.seen_welcome?
        return_to = session.delete(:return_to)
        if return_to.present? && return_to.start_with?('/')
          redirect_to return_to, notice: "Signed in successfully."
        else
          redirect_to after_sign_in_path_for(user), notice: "Signed in successfully."
        end
        return
      end

      # If we reach here, user has NOT seen the welcome -> send them to /welcome.
      # Keep session[:return_to] intact so we can return after onboarding.
      redirect_to welcome_path, notice: "Welcome to DevWerkhouz!"
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Signed out."
  end
end
