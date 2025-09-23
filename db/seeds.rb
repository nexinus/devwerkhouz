# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Reseed PromptTemplate table with 7 categories x 8 templates each = 56 templates total.
# WARNING: This will delete existing PromptTemplate records after backing them up to tmp/
require 'json'

timestamp = Time.now.to_i
backup_path = Rails.root.join("tmp", "prompt_templates_backup_#{timestamp}.json")

puts "== PromptTemplate reseed starting at #{Time.now} =="

# Backup existing records
begin
  data = PromptTemplate.all.as_json
  File.write(backup_path, JSON.pretty_generate(data))
  puts "Backed up #{data.length} PromptTemplate records to #{backup_path}"
rescue => e
  puts "Backup failed: #{e.message}"
end

ActiveRecord::Base.transaction do
  puts "Deleting existing PromptTemplate records..."
  PromptTemplate.delete_all
  puts "Deleted."

  templates = []

  # Category: Writing & Content (8)
  templates += [
    { title: "Blog Intro (3-paragraph)", category: "Writing & Content",
      prompt_text: "Write a compelling 3-paragraph introduction for a blog post about {{topic}} aimed at {{audience}}. Include a hook, problem statement, and what the article will cover.",
      tone: "Neutral", format: "Paragraph", audience: "General", length: "medium", public: true },

    { title: "Long-form Outline", category: "Writing & Content",
      prompt_text: "Create a detailed outline for a long-form article (2000-2500 words) on {{topic}}. Include headings, subheadings, and bullet points for each section.",
      tone: "Professional", format: "Outline", audience: "Writers", length: "long", public: true },

    { title: "SEO Blog Post Brief", category: "Writing & Content",
      prompt_text: "Generate an SEO-focused brief for a blog post on {{keyword}}: target audience, title options, meta description (155 chars), headings (H1-H3), and suggested keywords.",
      tone: "Professional", format: "Bullet list", audience: "Content Marketers", length: "medium", public: true },

    { title: "Product Description (short)", category: "Writing & Content",
      prompt_text: "Write a concise 60-80 word product description for {{product_name}}, focusing on top benefit and use case. Include 1 short CTA.",
      tone: "Persuasive", format: "Paragraph", audience: "Consumers", length: "short", public: true },

    { title: "Email Newsletter Intro", category: "Writing & Content",
      prompt_text: "Write a warm, engaging 2-3 sentence intro for a newsletter about {{topic}}, encouraging users to click through to the main article.",
      tone: "Friendly", format: "Paragraph", audience: "Subscribers", length: "short", public: true },

    { title: "Press Release Opening", category: "Writing & Content",
      prompt_text: "Draft the opening paragraph of a press release announcing {{event}} with who, what, when, where, and why in inverted pyramid style.",
      tone: "Formal", format: "Paragraph", audience: "Journalists", length: "short", public: true },

    { title: "Case Study Summary", category: "Writing & Content",
      prompt_text: "Summarize a case study about {{client}} in 3 sections: Challenge, Solution, Results — each 2-3 sentences.",
      tone: "Professional", format: "Bullet list", audience: "B2B Buyers", length: "medium", public: true },

    { title: "Meta Description Generator", category: "Writing & Content",
      prompt_text: "Create 5 unique meta descriptions (max 155 chars) for a page about {{topic}} aimed at {{audience}}.",
      tone: "Neutral", format: "Bullet list", audience: "SEOs", length: "short", public: true }
  ]

  # Category: Marketing & Growth (8)
  templates += [
    { title: "Short Marketing Ad (20 words)", category: "Marketing & Growth",
      prompt_text: "Write a short 20-word marketing ad for {{product}} focusing on the primary benefit and a clear call-to-action.",
      tone: "Persuasive", format: "Short social post", audience: "General", length: "short", public: true },

    { title: "Facebook Ad Copy (single image)", category: "Marketing & Growth",
      prompt_text: "Create 3 variations of Facebook ad copy for {{product}} (single image). Include headline (max 40 chars) and body (1-2 lines).",
      tone: "Persuasive", format: "Bullet list", audience: "Marketers", length: "short", public: true },

    { title: "Landing Page Hero", category: "Marketing & Growth",
      prompt_text: "Write headline, subheadline, and 3 bullet benefit statements for a landing page for {{product_or_service}} targeting {{audience}}.",
      tone: "Persuasive", format: "Bullet list", audience: "Conversion", length: "short", public: true },

    { title: "Email Outreach (cold)", category: "Marketing & Growth",
      prompt_text: "Draft a concise cold outreach email to {{role}} offering {{product}}. Include subject line and 2 short paragraphs with a CTA.",
      tone: "Professional", format: "Email (subject + body)", audience: "Prospects", length: "short", public: true },

    { title: "Content Calendar Ideas", category: "Marketing & Growth",
      prompt_text: "Generate 12 weekly content ideas for social and blog for {{brand}} focused on {{theme}}. Provide a one-line brief per idea.",
      tone: "Casual", format: "Bullet list", audience: "Social Managers", length: "medium", public: true },

    { title: "Value Proposition Statement", category: "Marketing & Growth",
      prompt_text: "Write a single-sentence value proposition for {{product}} that highlights the target audience, main benefit, and differentiator.",
      tone: "Authoritative", format: "Paragraph", audience: "Founders", length: "short", public: true },

    { title: "Ad A/B Test Variations", category: "Marketing & Growth",
      prompt_text: "Provide 6 ad headline + body variations to A/B test for {{campaign}} targeting {{audience}}.",
      tone: "Persuasive", format: "Bullet list", audience: "Ad Ops", length: "short", public: true },

    { title: "Customer Persona", category: "Marketing & Growth",
      prompt_text: "Create a 1-page customer persona for {{product}} including demographics, pain points, buying triggers, and a short messaging suggestion.",
      tone: "Professional", format: "Bullet list", audience: "Marketers", length: "medium", public: true }
  ]

  # Category: Business & Productivity (8)
  templates += [
    { title: "Meeting Agenda (Standup)", category: "Business & Productivity",
      prompt_text: "Create a concise agenda for a 15-minute stand-up: 3 sections (Yesterday, Today, Blockers) and suggested time allotments.",
      tone: "Professional", format: "Bullet list", audience: "Team", length: "short", public: true },

    { title: "Project Plan Outline", category: "Business & Productivity",
      prompt_text: "Produce an actionable 8-step project plan outline for {{project_name}} with owners and estimated timeframes for each step.",
      tone: "Professional", format: "Steps", audience: "Project Managers", length: "long", public: true },

    { title: "Sales Email Follow-up", category: "Business & Productivity",
      prompt_text: "Write a polite follow-up email to a prospect referencing a prior meeting about {{topic}} and asking for next steps. Include subject line.",
      tone: "Professional", format: "Email (subject + body)", audience: "Sales", length: "short", public: true },

    { title: "Job Description (senior)", category: "Business & Productivity",
      prompt_text: "Draft a senior role job description for {{role}} including responsibilities, required skills, and a short company blurb.",
      tone: "Formal", format: "Bullet list", audience: "HR", length: "medium", public: true },

    { title: "Meeting Notes Summary", category: "Business & Productivity",
      prompt_text: "Summarize the meeting notes below into action items, decisions, and owners. Use short bullets and deadlines when available.\n\n{{meeting_notes}}",
      tone: "Neutral", format: "Bullet list", audience: "Team", length: "short", public: true },

    { title: "OKR Draft", category: "Business & Productivity",
      prompt_text: "Draft 3 OKRs (Objective + 3 Key Results each) for a Q2 goal: {{objective}}. Keep KRs measurable and time-bound.",
      tone: "Professional", format: "Bullet list", audience: "Leadership", length: "short", public: true },

    { title: "One-page Report", category: "Business & Productivity",
      prompt_text: "Create a one-page status report template with sections for summary, metrics, risks, and next steps.",
      tone: "Professional", format: "Outline", audience: "Managers", length: "medium", public: true },

    { title: "Cold Outreach Script (phone)", category: "Business & Productivity",
      prompt_text: "Write a short phone outreach script for contacting {{prospect_type}} with a quick pitch and two bridging questions.",
      tone: "Conversational", format: "Script / Dialogue", audience: "Sales", length: "short", public: true }
  ]

  # Category: Code & Tech (8)
  templates += [
    { title: "Bug Reproduction Steps", category: "Code & Tech",
      prompt_text: "Write clear, numbered steps to reproduce the bug: {{bug_summary}}. Include environment (OS, browser), expected result, and actual result.",
      tone: "Technical", format: "Steps", audience: "Developer", length: "short", public: true },

    { title: "Code Review Checklist", category: "Code & Tech",
      prompt_text: "Provide a concise code review checklist for a backend PR (tests, security, performance, readability, edge cases).",
      tone: "Technical", format: "Bullet list", audience: "Engineers", length: "short", public: true },

    { title: "API Docs Example", category: "Code & Tech",
      prompt_text: "Draft an example request and response for the API endpoint {{endpoint}} including sample JSON and explanation of fields.",
      tone: "Technical", format: "Paragraph", audience: "Developers", length: "short", public: true },

    { title: "Refactor Plan", category: "Code & Tech",
      prompt_text: "Outline a step-by-step refactor plan to improve {{module}} for readability and performance without changing external behavior.",
      tone: "Technical", format: "Steps", audience: "Engineers", length: "medium", public: true },

    { title: "SQL Query Optimizer", category: "Code & Tech",
      prompt_text: "Given this SQL query: {{sql}}, suggest optimizations, indexing recommendations, and expected complexity improvements.",
      tone: "Technical", format: "Paragraph", audience: "DBAs", length: "medium", public: true },

    { title: "Unit Test Generator", category: "Code & Tech",
      prompt_text: "Generate 5 unit test cases for the function {{function_signature}} covering normal and edge cases, with brief assertions.",
      tone: "Technical", format: "Bullet list", audience: "Engineers", length: "short", public: true },

    { title: "Dev Environment Setup", category: "Code & Tech",
      prompt_text: "Write step-by-step instructions to set up a local dev environment for {{project_name}} on macOS, including deps and common gotchas.",
      tone: "Technical", format: "Steps", audience: "Developers", length: "long", public: true },

    { title: "PR Description Template", category: "Code & Tech",
      prompt_text: "Create a pull request description template with sections: Summary, Motivation, How to test, Screenshots, and Rollback plan.",
      tone: "Technical", format: "Bullet list", audience: "Engineers", length: "short", public: true }
  ]

  # Category: Learning & Knowledge (8)
  templates += [
    { title: "Language Drill (Flashcards)", category: "Learning & Knowledge",
      prompt_text: "Generate 10 flashcards for practicing {{language}} prepositions. Format each as 'Term — Example sentence — Translation'.",
      tone: "Neutral", format: "Bullet list", audience: "Learners", length: "short", public: true },

    { title: "Exam Practice Questions", category: "Learning & Knowledge",
      prompt_text: "Create 10 practice exam questions (multiple choice) on {{subject}} with one correct answer and brief explanation for each.",
      tone: "Academic", format: "Bullet list", audience: "Students", length: "medium", public: true },

    { title: "Summarize Article", category: "Learning & Knowledge",
      prompt_text: "Summarize the article text below in 5 key points and a 2-sentence TL;DR.\n\n{{article_text}}",
      tone: "Neutral", format: "Bullet list", audience: "Researchers", length: "short", public: true },

    { title: "Study Plan (2 weeks)", category: "Learning & Knowledge",
      prompt_text: "Create a 2-week study plan for learning {{topic}} with daily objectives and recommended resources.",
      tone: "Helpful", format: "Steps", audience: "Learners", length: "medium", public: true },

    { title: "Explain Like I'm 5", category: "Learning & Knowledge",
      prompt_text: "Explain {{concept}} in simple terms suitable for a 5-year-old, with 2 analogies.",
      tone: "Friendly", format: "Paragraph", audience: "Beginners", length: "short", public: true },

    { title: "Flashcard Quiz (fill-in)", category: "Learning & Knowledge",
      prompt_text: "Create a 10-item fill-in-the-blank quiz on {{topic}} with answers provided at the end.",
      tone: "Neutral", format: "Bullet list", audience: "Students", length: "short", public: true },

    { title: "Research Paper Outline", category: "Learning & Knowledge",
      prompt_text: "Provide a structured outline for a research paper on {{topic}} including sections and brief notes on what to cover in each.",
      tone: "Academic", format: "Outline", audience: "Researchers", length: "long", public: true },

    { title: "Mnemonic Creator", category: "Learning & Knowledge",
      prompt_text: "Create a memorable mnemonic to help remember the list: {{list_items}} and explain why it works.",
      tone: "Helpful", format: "Paragraph", audience: "Learners", length: "short", public: true }
  ]

  # Category: Creative & Design (8)
  templates += [
    { title: "Brand Name Brainstorm", category: "Creative & Design",
      prompt_text: "Provide 20 brand name ideas for a sustainable home-office products line. Include a one-line rationale for each name.",
      tone: "Playful", format: "Bullet list", audience: "Founders", length: "medium", public: true },

    { title: "Logo Concept Brief", category: "Creative & Design",
      prompt_text: "Write a short creative brief for a logo: desired style, colors, must-have symbols, and 3 mood keywords for {{brand}}.",
      tone: "Creative", format: "Paragraph", audience: "Designers", length: "short", public: true },

    { title: "UX Microcopy (CTA)", category: "Creative & Design",
      prompt_text: "Generate 10 alternative microcopy CTAs for a signup button to improve conversions for {{audience}}.",
      tone: "Friendly", format: "Bullet list", audience: "Product", length: "short", public: true },

    { title: "Moodboard Description", category: "Creative & Design",
      prompt_text: "Describe a moodboard for a premium, eco-friendly product: textures, colors, photography style, and typography suggestions.",
      tone: "Creative", format: "Paragraph", audience: "Designers", length: "medium", public: true },

    { title: "Video Script Hook (30s)", category: "Creative & Design",
      prompt_text: "Write a 30-second video script hook for {{product}} that captures attention in first 5 seconds and ends with CTA.",
      tone: "Playful", format: "Script / Dialogue", audience: "Marketers", length: "short", public: true },

    { title: "Naming Check (domain)", category: "Creative & Design",
      prompt_text: "Suggest 10 brand names for {{product}} and append a suggestion whether the .com domain is likely to be available (yes/no/unknown).",
      tone: "Creative", format: "Bullet list", audience: "Founders", length: "short", public: true },

    { title: "Poster Taglines", category: "Creative & Design",
      prompt_text: "Generate 12 short poster taglines (6-8 words) promoting {{event}} with emphasis on urgency and emotion.",
      tone: "Persuasive", format: "Bullet list", audience: "Event Planners", length: "short", public: true },

    { title: "Color Palette Suggestions", category: "Creative & Design",
      prompt_text: "Recommend 5 color palettes (each with 3 hex codes) suitable for a modern sustainable brand and short rationale.",
      tone: "Creative", format: "Bullet list", audience: "Designers", length: "short", public: true }
  ]

  # Category: Personal & Miscellaneous (8)
  templates += [
    { title: "Daily Journal Prompt", category: "Personal & Miscellaneous",
      prompt_text: "Write a short daily journal prompt that helps the user list three wins from today and one improvement action for tomorrow.",
      tone: "Friendly", format: "Paragraph", audience: "Self", length: "short", public: true },

    { title: "Meal Plan (3 days)", category: "Personal & Miscellaneous",
      prompt_text: "Generate a simple 3-day meal plan for {{diet_preference}} including breakfast, lunch, and dinner with quick recipes.",
      tone: "Helpful", format: "Bullet list", audience: "General", length: "medium", public: true },

    { title: "Workout Routine (30-min)", category: "Personal & Miscellaneous",
      prompt_text: "Create a 30-minute full-body workout routine for {{fitness_level}} including warm-up, main sets, and cooldown.",
      tone: "Encouraging", format: "Steps", audience: "Individuals", length: "short", public: true },

    { title: "Travel Packing List", category: "Personal & Miscellaneous",
      prompt_text: "Generate a packing checklist for a {{trip_type}} trip lasting {{n_days}} days, including essentials and optional items.",
      tone: "Practical", format: "Bullet list", audience: "Travelers", length: "short", public: true },

    { title: "Simple Meditation Guide", category: "Personal & Miscellaneous",
      prompt_text: "Write a 5-minute guided meditation script focusing on breath and grounding for beginners.",
      tone: "Calm", format: "Paragraph", audience: "Beginners", length: "short", public: true },

    { title: "Birthday Message Ideas", category: "Personal & Miscellaneous",
      prompt_text: "Provide 10 birthday message options (casual, funny, heartfelt) for {{relationship}} to use in a card.",
      tone: "Playful", format: "Bullet list", audience: "General", length: "short", public: true },

    { title: "Habit Tracker Template", category: "Personal & Miscellaneous",
      prompt_text: "Create a simple weekly habit tracker template with 7 habits and a scoring system to measure consistency.",
      tone: "Helpful", format: "Table", audience: "Self-improvement", length: "short", public: true },

    { title: "Goal Setting Worksheet", category: "Personal & Miscellaneous",
      prompt_text: "Provide a one-page goal-setting worksheet with sections for goal, why it matters, obstacles, first actions, and checkpoints.",
      tone: "Motivational", format: "Outline", audience: "Individuals", length: "medium", public: true }
  ]

  # Create records
  puts "Creating #{templates.length} PromptTemplate records..."
  templates.each do |attrs|
    PromptTemplate.create!(
      title: attrs[:title],
      prompt_text: attrs[:prompt_text],
      category: attrs[:category],
      tone: attrs[:tone],
      format: attrs[:format],
      audience: attrs[:audience],
      length: attrs[:length],
      public: attrs.fetch(:public, true)
    )
  end

  puts "Successfully created #{templates.length} templates."
end

puts "== Reseed finished at #{Time.now} =="
puts "Backup file: #{backup_path}"
