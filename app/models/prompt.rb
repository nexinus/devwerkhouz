class Prompt < ApplicationRecord
  belongs_to :user

  validates :idea, presence: true
  validates :generated_prompt, presence: true
end
