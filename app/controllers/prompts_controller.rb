class PromptsController < ApplicationController
  def new
  end

  def create
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
        model: "gpt-4-turbo",
        messages: [
          { role: "system", content: "You are a helpful prompt engineer." },
          { role: "user", content: system_prompt }
        ],
        temperature: 0.3
      }
    )

    @generated_prompt = response.dig("choices", 0, "message", "content")
    render :show
  rescue => e
    @error = "AI service error: #{e.message}"
    render :new, status: :service_unavailable
  end
end
