class PagesController < ApplicationController
  def home
    # show a composer-first experience for logged in users later
    @generated_prompt = flash[:generated_prompt] # optional
    # ensure the prompt form has a model object (prevents `undefined method 'idea' for false`)
    @prompt = Prompt.new

    # optionally pass preview prompts for visitors (only show user prompts when signed in)
    @sample_prompts = Prompt.order(created_at: :desc).limit(3) unless user_signed_in?
    @sample_prompts = current_user.prompts.order(created_at: :desc).limit(3) if user_signed_in?
  end

  def pricing
  end

  def privacy; end
  def terms; end
  def impressum; end
end
