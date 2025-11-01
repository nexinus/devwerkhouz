# Ensure OmniAuth listens on the same prefix that Devise expects.
# This avoids "Authentication passthru" when the middleware and Devise
# disagree about the path prefix.
OmniAuth.config.path_prefix = '/users/auth'

# Prefer Rails credentials; fall back to ENV for local development.
google_client_id     = Rails.application.credentials.dig(:google, :client_id) || ENV['GOOGLE_CLIENT_ID']
google_client_secret = Rails.application.credentials.dig(:google, :client_secret) || ENV['GOOGLE_CLIENT_SECRET']

if google_client_id.present? && google_client_secret.present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
             google_client_id,
             google_client_secret,
             scope: 'email,profile',
             prompt: 'select_account',
             hd: nil
  end
end
