OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    # Optional: config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID")
  end
