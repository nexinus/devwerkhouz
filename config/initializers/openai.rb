# config/initializers/openai.rb
openai_token = ENV["OPENAI_ACCESS_TOKEN"] || ENV["OPENAI_API_KEY"]

if openai_token && !openai_token.empty?
  OpenAI.configure do |config|
    config.access_token = openai_token
  end
  Rails.logger.info("[OpenAI] configured OpenAI client")
else
  Rails.logger.warn("[OpenAI] OPENAI_ACCESS_TOKEN not set — OpenAI client not configured (safe for asset precompile/build).")
end
