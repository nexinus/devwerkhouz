class PromptTemplatesController < ApplicationController
    before_action :authenticate_user!, only: [:create, :like]
  
    def index
      @category = params[:category]
      @templates = if @category.present?
                     PromptTemplate.public_templates.by_category(@category).order(likes_count: :desc)
                   else
                     PromptTemplate.public_templates.order(likes_count: :desc).limit(50)
                   end
    end
  
    def show
      @template = PromptTemplate.find(params[:id])
    end
  
    def create
      # Only trusted users should create public templates; for MVP allow any signed-in user
      @template = current_user ? current_user.prompt_templates.build(template_params) : PromptTemplate.new(template_params)
      if @template.save
        redirect_to prompt_template_path(@template), notice: "Template added."
      else
        flash.now[:alert] = @template.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end
  
    def like
      @template = PromptTemplate.find(params[:id])
      @template.increment!(:likes_count)
      respond_to do |format|
        format.turbo_stream { head :ok } # or return a small partial update
        format.html { redirect_back fallback_location: prompt_templates_path }
      end
    end
  
    def categories
      @categories = PromptTemplate.distinct.pluck(:category).sort
      render json: @categories
    end
  
    private
  
    def template_params
      params.require(:prompt_template).permit(:title, :prompt_text, :category, :public)
    end
  end
  