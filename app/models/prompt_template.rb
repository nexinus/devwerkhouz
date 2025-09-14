class PromptTemplate < ApplicationRecord
  belongs_to :author, class_name: "User", optional: true

  validates :title, presence: true
  validates :prompt_text, presence: true
  validates :category, presence: true

  scope :public_templates, -> { where(public: true) }
  scope :by_category, ->(cat) { where(category: cat) }
end
