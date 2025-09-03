class PagesController < ApplicationController
  def home
    # optionally pass preview prompts for visitors
    @sample_prompts = Prompt.order(created_at: :desc).limit(3) if user_signed_in?
  end
  def privacy; end
  def terms; end
  def impressum; end
end