class PromptsController < ApplicationController
  before_action :authenticate_user!

  def index
    @prompts = current_user.prompts.order(created_at: :desc).limit(50)
  end

  def new
    @prompt = Prompt.new(idea: params.dig(:prompt, :idea) || params[:idea])
  end

  def create
    idea = params.dig(:prompt, :idea)
    category = params.dig(:prompt, :category)
    tone = params.dig(:prompt, :tone)
    format = params.dig(:prompt, :format)

    system_prompt = <<~PROMPT
      You are a professional prompt engineer. Create a single concise and clear prompt for a large language model based on the user's idea below.

      User idea: #{idea}
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

    # set local variable and instance var for templates
    generated = response.dig("choices", 0, "message", "content")&.strip
    @generated_prompt = generated

    # save prompt for current_user (user is required per your model)
    @prompt = current_user.prompts.build(
      idea: idea,
      generated_prompt: generated,
      category: category,
      tone: tone,
      format: format
    )

    if @prompt.save
      # store previous input so Back/Edit works
      @previous_input = { idea: idea, category: category, tone: tone, format: format }

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
      @previous_input = { idea: idea, category: category, tone: tone, format: format }
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("prompt_form", partial: "prompts/form", locals: { prompt: @prompt }) }
        format.html { flash.now[:alert] = @error; render :new, status: :unprocessable_entity }
      end
    end
  rescue => e
    @error = "AI service error: #{e.message}"
    @previous_input = { idea: idea, category: category, tone: tone, format: format }
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("prompt_form", partial: "prompts/form", locals: { prompt: Prompt.new(idea: idea) }) }
      format.html { flash.now[:alert] = @error; render :new, status: :service_unavailable }
    end
  end

  def show
    @prompt = current_user.prompts.find(params[:id])
    respond_to do |format|
      format.html
      format.turbo_stream { render partial: "prompts/show_frame", locals: { prompt: @prompt } }
    end
  end
end
