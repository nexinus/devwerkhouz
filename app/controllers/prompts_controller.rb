class PromptsController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  protect_from_forgery with: :exception

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

    # If user is signed in -> persist and update sidebar history; otherwise keep ephemeral
    if user_signed_in?
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

    else
      # Guest user: don't save (Prompt.belongs_to :user requires a user_id)
      @prompt = Prompt.new(
        idea: idea,
        generated_prompt: generated,
        category: category,
        tone: tone,
        format: format
      )

      # Return the result to the page (Turbo stream or full HTML)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("prompt_show", partial: "prompts/show_frame", locals: { prompt: @prompt })
        end

        format.html { render :show }
      end
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

  def execute
    prompt = Prompt.find(params[:id])
    prompt_text = prompt.generated_prompt.to_s

    begin
      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
      response = client.chat.completions.create(
        model: "gpt-4o-mini", # choose your model
        messages: [
          { role: "system", content: "You are a helpful assistant." },
          { role: "user", content: prompt_text }
        ],
        max_tokens: 800
      )

      assistant_text = response.dig("choices", 0, "message", "content") || "No response."

      render json: { ok: true, assistant: assistant_text }
    rescue => e
      Rails.logger.error("OpenAI error: #{e.class} #{e.message}")
      render json: { ok: false, error: e.message }, status: 500
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
