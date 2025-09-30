class DashboardController < ApplicationController
    before_action :authenticate_user!
  
    def show
      @prompt = Prompt.new
      # Optional: load recent or favourite prompts for this user
      @saved_prompts = current_user.prompts.order(updated_at: :desc).limit(10) if current_user
    end
  end
  