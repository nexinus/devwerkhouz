Rails.application.config.session_store :cookie_store,
  key: "_devwerkhouz_session",
  same_site: :lax,
  secure: Rails.env.production?  # false in development so cookie is sent over http
