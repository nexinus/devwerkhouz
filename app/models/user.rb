# app/models/user.rb
class User < ApplicationRecord
  # Devise modules
  # Available modules: :confirmable, :lockable, :timeoutable, :trackable, :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # Remove has_secure_password: Devise manages encryption via `encrypted_password`.
  # has_secure_password # <-- removed

  has_many :prompts, dependent: :destroy
  has_many :prompt_templates, foreign_key: :author_id, dependent: :nullify

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  # Called by Omniauth callbacks controller
  # `auth` is the OmniAuth auth hash (omniauth-google-oauth2)
  def self.from_omniauth(auth)
    provider = auth.provider
    uid = auth.uid
    email = auth.info&.email
    name  = auth.info&.name || email.to_s.split('@').first

    # 1) Find by provider+uid (OAuth users)
    user = find_by(provider: provider, uid: uid)

    # 2) If not found, try to find by email (user may have signed up with email before)
    user ||= find_by(email: email) if email.present?

    if user
      # If user existed but provider/uid missing, set them (non-destructive)
      if user.provider.blank? || user.uid.blank?
        user.update(provider: provider, uid: uid)
      end
      return user
    end

    # 3) Create new user. We set a random password because Devise requires it, but users sign in via Google.
    create!(
      provider: provider,
      uid: uid,
      email: email,
      name: name,
      password: Devise.friendly_token[0, 20],
      # If you use :confirmable and want to auto-confirm OAuth users, uncomment:
      # confirmed_at: Time.current
    )
  end

  # Return avatar URL stored on the user, or fallback to Gravatar, or nil.
  def avatar_url
    # prefer explicit avatar_url column if present
    url = self[:avatar_url].presence
    return url if url.present?

    # fallback: gravatar based on email, if available
    if email.present?
      hash = Digest::MD5.hexdigest(email.strip.downcase)
      "https://www.gravatar.com/avatar/#{hash}?s=200&d=identicon"
    else
      nil
    end
  end
end
