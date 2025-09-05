class PromptsController < ApplicationController
  before_action :authenticate_user!

  def index
    @prompts = current_user.prompts.order(created_at: :desc).limit(50)
  end

  def new
    # prefill from params (useful when linking back to edit)
    @prompt = Prompt.new(idea: params.dig(:prompt, :idea) || params[:idea])
  end

  def create
    # Accept either nested params[:prompt][:idea] OR top-level params[:idea]
    idea     = params.dig(:prompt, :idea) || params[:idea]
    category = params.dig(:prompt, :category) || params[:category]
    tone     = params.dig(:prompt, :tone) || params[:tone]
    format   = params.dig(:prompt, :format) || params[:format]

    # Keep a previous input hash to repopulate the form if needed
    @previous_input = { idea: idea, category: category, tone: tone, format: format }

    # Guard: idea required
    unless idea.present?
      @error = "Please enter an idea to generate a prompt."
      return render_new_with_error
    end

    # Build the system prompt for the LLM
    system_prompt = <<~PROMPT
      You are a professional prompt engineer. Create a single concise and clear prompt for a large language model based on the user's idea below.

      User idea: #{idea}
      Category: #{category}
      Tone: #{tone}
      Desired format: #{format}

      Output only the final prompt. Do not include explanations.
    PROMPT

    # Call the AI
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You are a helpful prompt engineer." },
          { role: "user", content: system_prompt }
        ],
        temperature: 0.3
      }
    )

    # Use a single local variable and instance var for the result
    generated = response.dig("choices", 0, "message", "content")&.strip
    @generated_prompt = generated

    if generated.blank?
      @error = "AI returned no content. Try again."
      return render_new_with_error
    end

    # Save as current_user.prompt (your Prompt model requires a user)
    @prompt = current_user.prompts.build(
      idea: idea,
      generated_prompt: generated,
      category: category,
      tone: tone,
      format: format
    )

    if @prompt.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("prompt_show", partial: "prompts/show_frame", locals: { prompt: @prompt }),
            turbo_stream.prepend("sidebar_history", partial: "prompts/sidebar_item", locals: { prompt: @prompt })
          ]
        end

        format.html { redirect_to prompt_path(@prompt), notice: "Prompt generated and saved." }
      end
    else
      @error = @prompt.errors.full_messages.to_sentence
      render_new_with_error
    end

  rescue OpenAI::Error => e
    @error = "AI service error: #{e.message}"
    render_new_with_error
  rescue => e
    @error = "Unexpected error: #{e.message}"
    render_new_with_error
  end

  def show
    @prompt = current_user.prompts.find(params[:id])
    respond_to do |format|
      format.html
      format.turbo_stream { render partial: "prompts/show_frame", locals: { prompt: @prompt } }
    end
  end

  private

  def render_new_with_error
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("prompt_form", partial: "prompts/form", locals: { prompt: @prompt || Prompt.new }) }
      format.html { flash.now[:alert] = @error; render :new, status: :unprocessable_entity }
    end
  end
end
