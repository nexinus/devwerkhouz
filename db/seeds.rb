# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
CATEGORIES = [
  "Writing & Content",
  "Marketing & Growth",
  "Business & Productivity",
  "Code & Tech",
  "Learning & Knowledge",
  "Creative & Design",
  "Personal & Miscellaneous"
]

PromptTemplate.create!([
  { title: "Blog Intro (3-paragraph)", category: "Writing & Content", prompt_text: "Write a compelling 3-paragraph introduction for a blog post about {{topic}}." },
  { title: "Short Marketing Ad", category: "Marketing & Growth", prompt_text: "Write a short 20-word marketing ad for {{product}} with a clear call-to-action." },
  { title: "Meeting Agenda (Standup)", category: "Business & Productivity", prompt_text: "Create a concise agenda for a 15-minute team stand-up covering updates and blockers." },
  { title: "Bug Reproduction Steps", category: "Code & Tech", prompt_text: "Write clear steps to reproduce the bug: {{bug_summary}} including environment, expected result, actual result." },
  { title: "Language Drill (Flashcards)", category: "Learning & Knowledge", prompt_text: "Generate 10 flashcards for practicing {{language}} prepositions with examples." },
  { title: "Brand Name Brainstorm", category: "Creative & Design", prompt_text: "Provide 20 brand name ideas for a sustainable home-office products line." },
  { title: "Daily Journal Prompt", category: "Personal & Miscellaneous", prompt_text: "Write a short daily journal prompt to reflect on three wins and one improvement area." }
])
