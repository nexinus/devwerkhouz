# DevWerkHouz — README & Launch Plan

> **Project:** DevWerkHouz — Minimal AI Prompt Generator (MVP)
>
> **Goal:** Launch a minimalist Rails-based MVP that generates high-quality AI prompts for general users using OpenAI (gpt-4-turbo).
>
> **Domain:** `devwerkhouz.com`
> **Owner:** Zulkarnain bin Mohamed
> **Tech stack:** Ruby 3.2+, Rails 8+, Tailwind CSS, Docker, Kamal for deploy, `ruby-openai` gem
> **Agent:** Cursor AI (sole developer)

---

## 1 — Project Overview (MVP Scope)

Minimal, fast-to-launch web app focused on one thing: **generate the best possible prompt** for a user’s AI request.

Core features for Day‑1 (MVP):

* Home page with short explainer + tagline
* Prompt Generator page with:

  * Input text area for the user idea / intent
  * Category dropdown: `Writing`, `Business`, `Creative`, `Education`
  * Tone dropdown: `Formal`, `Casual`, `Persuasive`
  * Format dropdown: `Paragraph`, `List`, `Bullets`
  * `Generate Prompt` button
* Results view showing the generated *final prompt* ready to copy
* Static legal pages: Privacy Policy, Terms of Service, Impressum (GDPR-friendly)
* SEO-friendly meta tags and three tagline options

Non-persistent MVP: do not store user prompts in DB by default (privacy-first). Option to save favorites later under user accounts.

---

## 2 — Quickstart (What you / Cursor will do first)

**Prerequisites (local dev machine):**

* Ruby 3.2+, Node.js 18+, PostgreSQL or SQLite (dev), Git
* Docker & Docker Compose (for deployment with Kamal)
* Cursor app installed and connected to your GitHub repo (optional but recommended)

**Quick commands:**

```bash
# create rails app (locally or let Cursor run it)
rails new devwerkhouz --css tailwind --database=postgresql
cd devwerkhouz
git init
git add .
git commit -m "Initial scaffold"
# push to GitHub (replace with your repo url)
git remote add origin git@github.com:nexinus/devwerkhouz.git
git branch -M main
git push -u origin main
```

**Important:** Do **not** commit secrets (API keys, `.env`). Use environment variables.

---

## 3 — Starter Prompt (paste this to Cursor)

```
You are my senior Ruby on Rails developer. Build a minimal MVP for devwerkhouz.com: an AI Prompt Generator (Rails 8 + Tailwind) using OpenAI (gpt-4-turbo).

Scope:
- Home, Prompt Generator page (input + category + tone + format), Results view
- Use `ruby-openai` gem and read `OPENAI_ACCESS_TOKEN` from ENV
- Minimal design, Tailwind for styling
- No DB storage for user prompts in MVP
- Add Privacy, Terms, Impressum pages

Repository: https://github.com/nexinus/devwerkhouz.git

Start by:
1) Creating Rails project skeleton and pushing to repo
2) Adding `ruby-openai` gem and initializer for the API key
3) Scaffolding `PromptsController` and views for the form + result
4) Commit after each major step and list commands run

Keep responses short with code snippets and file paths. Ask "Next task" when ready for the next step.

---

## 4 — Full Cursor Agent Prompt (detailed)

> Use this if you want Cursor to autonomously run through the entire build-and-deploy. Paste into Cursor only after the repo and README are pushed.

```
You are Cursor, acting as the sole developer for DevWerkHouz. Build, test and deploy a Rails 8 app (Ruby 3.2+) with Tailwind. Use `ruby-openai` for GPT-4. Follow this checklist and create commits for each major milestone. Keep replies concise and include file paths and code snippets.

Checklist:
1) Create Rails app skeleton with Tailwind and Postgres (dev). Push to repo.
2) Add gem 'ruby-openai' and create `config/initializers/openai.rb` that reads `ENV['OPENAI_ACCESS_TOKEN']`.
3) Scaffold `PromptsController` with `new/create` actions and routes. Build views: `new.html.erb` for form, `show.html.erb` for result.
4) Implement OpenAI call in controller using `OpenAI::Client.new.chat(...)` and extract the generated prompt.
5) Add minimal layout and Tailwind classes for a clean UI.
6) Add three static pages: Privacy, Terms, Impressum (use GDPR boilerplate provided in README).
7) Add Dockerfile, `docker-compose.yml` (optional), and `config/deploy.yml` for Kamal. Provide exact deploy commands: `bin/kamal setup` then `bin/kamal deploy`.
8) Add basic tests (model/controller) and fix any RuboCop issues.
9) Provide a short deploy checklist and verify the GPT feature in production.

Security:
- Never commit secrets. Use ENV vars for `OPENAI_ACCESS_TOKEN`.
- Do not post API keys in the chat.

After each step, create a commit with a clear message and report the commands executed. When stuck, ask for a single clarifying question.
```

---

## 5 — Files & Code Snippets (copy/paste-ready)

**Gemfile additions**

```ruby
gem 'ruby-openai'
```

**config/initializers/openai.rb**

```ruby
# config/initializers/openai.rb
require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_ACCESS_TOKEN')
  # config.organization_id = ENV['OPENAI_ORG_ID'] if ENV['OPENAI_ORG_ID']
end
```

**PromptsController (basic example)**

```ruby
# app/controllers/prompts_controller.rb
class PromptsController < ApplicationController
  def new
  end

  def create
    user_input = params[:prompt][:idea]
    category = params[:prompt][:category]
    tone = params[:prompt][:tone]
    format = params[:prompt][:format]

    system_prompt = <<~PROMPT
      You are a professional prompt engineer. Create a single concise and clear prompt for a large language model based on the user's idea below.

      User idea: #{user_input}
      Category: #{category}
      Tone: #{tone}
      Desired format: #{format}

      Output only the final prompt. Do not include explanations.
    PROMPT

    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-4-turbo",
        messages: [
          { role: "system", content: "You are a helpful prompt engineer." },
          { role: "user", content: system_prompt }
        ],
        temperature: 0.3
      }
    )

    @generated_prompt = response.dig("choices",0,"message","content")
    render :show
  rescue => e
    @error = "AI service error: #{e.message}"
    render :new, status: :service_unavailable
  end
end
```

**Routes** (`config/routes.rb`)

```ruby
Rails.application.routes.draw do
  root "pages#home"
  resource :prompt, only: [:new, :create], controller: 'prompts'
  get "/privacy", to: "pages#privacy"
  get "/terms", to: "pages#terms"
  get "/impressum", to: "pages#impressum"
end
```

**Example form (app/views/prompts/new\.html.erb)**

```erb
<%= form_with url: prompt_path, method: :post, local: true do |f| %>
  <div>
    <%= f.label :idea, "Describe your idea" %>
    <%= f.text_area :idea, rows: 4, class: "w-full p-2 border rounded" %>
  </div>

  <div class="mt-2">
    <%= f.label :category %>
    <%= f.select :category, options_for_select(["Writing","Business","Creative","Education"]), {}, class: "p-2" %>
  </div>

  <div class="mt-2">
    <%= f.label :tone %>
    <%= f.select :tone, options_for_select(["Formal","Casual","Persuasive"]), {}, class: "p-2" %>
  </div>

  <div class="mt-2">
    <%= f.label :format %>
    <%= f.select :format, options_for_select(["Paragraph","List","Bullets"]), {}, class: "p-2" %>
  </div>

  <div class="mt-4">
    <%= f.submit "Generate Prompt", class: "px-4 py-2 rounded bg-blue-600 text-white" %>
  </div>
<% end %>
```

**Show view (app/views/prompts/show\.html.erb)**

```erb
<h2>Generated Prompt</h2>
<pre class="p-4 bg-gray-100 rounded"><%= @generated_prompt %></pre>
<div class="mt-4">
  <button onclick="navigator.clipboard.writeText(`<%= j @generated_prompt %>`)">Copy to clipboard</button>
</div>
```

---

## 6 — Docker & Kamal (deploy basics)

**Dockerfile (simple Rails)**

```dockerfile
FROM ruby:3.2
WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . ./
CMD ["/bin/bash","-lc","bundle exec puma -C config/puma.rb"]
```

**config/deploy.yml (Kamal)** — minimal example (fill in values)

```yaml
service: devwerkhouz
image: yourdockerhubusername/devwerkhouz
servers:
  - host: 1.2.3.4
    user: deploy
proxy:
  host: devwerkhouz.com
  ssl: true
```

**Deploy commands**

```bash
# build/push image locally
docker login
docker build -t yourdockerhubusername/devwerkhouz:latest .
docker push yourdockerhubusername/devwerkhouz:latest

# use kamal
bin/kamal setup   # first time
bin/kamal deploy
```

> If you prefer Render / Fly.io for speed, we can supply a Render service file or Fly config instead. Kamal + Docker on a small VPS gives control and free SSL via Let’s Encrypt.

---

## 7 — Legal Pages (boilerplate)

> **Privacy Policy** (short GDPR-friendly summary — adapt as needed):

```
DevWerkHouz (owned by Zulkarnain bin Mohamed) collects no personal data from anonymous users who use the prompt generator. We do not store prompts or inputs unless explicitly saved by the user. If you create an account, we store your email and encrypted password. API keys and payment info are never stored in the repo. For any data requests or deletion, contact: devwerkhouz.team@gmail.com
```

> **Terms of Service** (short):

```
By using DevWerkHouz, you agree that generated prompts are provided "as-is". We disclaim liability for outputs generated by external AI providers (OpenAI). Users are responsible for compliance with local law and OpenAI terms.
```

> **Impressum (German legal contact)**

```
DevWerkHouz
Owner: Zulkarnain bin Mohamed
Address: [Your registered business address in Germany]
Email: devwerkhouz.team@gmail.com
Phone: [optional]
Register: [local business registry info if applicable]
```

---

## 8 — Tagline & SEO (3 options)

1. **DevWerkHouz — The House for Perfect AI Prompts** (SEO: "AI prompt generator", "perfect AI prompts")
2. **DevWerkHouz — Your Home for Optimized AI Prompts** (SEO: "optimize prompts", "AI prompt optimizer")
3. **DevWerkHouz — Prompt Generator for Better AI Results** (SEO: "prompt generator", "AI prompt generator")

**Meta desc (example):** `DevWerkHouz — Generate optimized AI prompts in seconds. Minimal interface, powerful results. Try our free prompt builder for ChatGPT, GPT-4, and more.`

---

## 9 — Security & Privacy Checklist

* Store `OPENAI_ACCESS_TOKEN` as an environment variable on the host. Example (Linux):

```bash
export OPENAI_ACCESS_TOKEN="sk-..."
```

* Do NOT commit `.env` or any secrets to Git. Add `.env` to `.gitignore`.
* Enable 2FA on Gmail and GitHub. Use a password manager.
* For production, use Rails encrypted credentials or host-provided env var system.

---

## 10 — How to Feed the Full Plan to Cursor (best practice)

1. Push this README.md to the repo root and commit.
2. In Cursor, open the repo and let it index files.
3. Paste the **Starter Prompt** (section 3) into the Cursor chat and replace the repo placeholder with your repository URL.
4. Follow Cursor’s messages; give `Next task` one-liners when you want the next step executed.

---

## 11 — Next Steps / Launch checklist (short)

1. Create project repo and push README (this file).
2. Create Gmail `devwerkhouz.team@gmail.com` and enable 2FA.
3. Sign up to Cursor with that Gmail & connect repo.
4. Paste the Starter Prompt into Cursor.
5. Let Cursor scaffold project, then review commits and push changes.
6. Add OpenAI API key as env var on your dev / server.
7. Run local tests, then prepare Docker image and run `bin/kamal setup` + `bin/kamal deploy`.
8. Final QA and go-live.

---

## 12 — Contact

If you want, I can now generate the exact `.cursor` folder contents and a ready-to-commit `README.md` variant tailored for GitHub. Reply **"Generate files"** and I will produce the `.cursor` scaffolding and a copy of this README in a GitHub-ready format.

---

*End of README & Launch Plan for DevWerkHouz.*
