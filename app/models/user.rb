class User < ApplicationRecord
  has_secure_password

  has_many :prompts, dependent: :destroy
  has_many :prompt_templates, foreign_key: :author_id, dependent: :nullify

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
