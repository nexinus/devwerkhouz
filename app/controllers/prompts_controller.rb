class PromptsController < ApplicationController
  before_action :authenticate_user!

  def new
    # allow prefill from params or previously saved inputs
    @prompt = Prompt.new(idea: params.dig(:prompt, :idea) || params[:idea])
  end

  def create
    # accept either nested params[:prompt][:idea] OR top-level params[:idea]
    # user_input = params.dig(:prompt, :idea) || params[:idea]
    # category   = params.dig(:prompt, :category) || params[:category]
    # tone       = params.dig(:prompt, :tone) || params[:tone]
    # format     = params.dig(:prompt, :format) || params[:format]
    user_input = params.dig(:prompt, :idea)
    category = params.dig(:prompt, :category)
    tone = params.dig(:prompt, :tone)
    format = params.dig(:prompt, :format)

    system_prompt = <<~PROMPT
      You are a professional prompt engineer. Create a single concise and clear prompt for a large language model based on the user's idea below.

      User idea: #{user_input}
      Category: #{category}
      Tone: #{tone}
      Desired format: #{format}

      Output only the final prompt. Do not include explanations.
    PROMPT

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

    @generated_prompt = response.dig("choices", 0, "message", "content")

    # save prompt for current_user
    @prompt = current_user.prompts.create(
      idea: user_input,
      generated_prompt: generated,
      category: category,
      tone: tone,
      format: format
    )

    @generated_prompt = generated
    # keep the original user inputs so Back/Edit can repopulate the form
    @previous_input = {
      idea: user_input,
      category: category,
      tone: tone,
      format: format
    }
    render :show
  rescue => e
    @error = "AI service error: #{e.message}"
    # keep previously submitted values so form can repopulate
    @previous_input = { idea: user_input, category: category, tone: tone, format: format }
    render :new, status: :service_unavailable
  end

  def show
    @prompt = current_user.prompts.find(params[:id])
    # show view will render within a turbo frame if requested
    respond_to do |format|
      format.html # show.html.erb (full page)
      format.turbo_stream { render partial: "prompts/show_frame", locals: { prompt: @prompt } }
    end
  end

  # optional index (history)
  def index
    @prompts = current_user.prompts.order(created_at: :desc).limit(50)
  end
end
