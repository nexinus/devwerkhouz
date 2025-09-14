# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
PromptTemplate.find_or_create_by!(title: "Short marketing ad", category: "Marketing") do |t|
    t.prompt_text = "Write a short 20-word marketing ad for {{product}} focusing on benefit X and call to action."
    t.public = true
  end
  
  PromptTemplate.find_or_create_by!(title: "Blog intro", category: "Writing") do |t|
    t.prompt_text = "Write a compelling 3-paragraph introduction for a blog post about {{topic}} aimed at {{audience}}."
    t.public = true
  end
  