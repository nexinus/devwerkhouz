# Ensure OmniAuth listens on the same prefix that Devise expects.
# This avoids "Authentication passthru" when the middleware and Devise
# disagree about the path prefix.
OmniAuth.config.path_prefix = '/users/auth'

# Also tell Devise what path prefix to expect for omniauth routes.
Devise.omniauth_path_prefix = '/users/auth'

# Allow both GET and POST: GET for callbacks from OAuth providers, POST for initiating auth
OmniAuth.config.allowed_request_methods = [:get, :post]

# Configure OmniAuth to raise errors in development for better debugging
OmniAuth.config.failure_raise_out_environments = ['development']

# Prefer Rails credentials; fall back to ENV for local development.
google_client_id     = Rails.application.credentials.dig(:google, :client_id) || ENV['GOOGLE_CLIENT_ID']
google_client_secret = Rails.application.credentials.dig(:google, :client_secret) || ENV['GOOGLE_CLIENT_SECRET']

if google_client_id.present? && google_client_secret.present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
             google_client_id,
             google_client_secret,
             scope: 'userinfo.email, userinfo.profile',
             prompt: 'select_account',
             access_type: 'offline',
             hd: nil
  end
end
