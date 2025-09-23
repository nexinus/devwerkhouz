# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_18_071516) do
  create_table "prompt_templates", force: :cascade do |t|
    t.string "title", null: false
    t.text "prompt_text", null: false
    t.string "category", default: "Other", null: false
    t.integer "author_id"
    t.boolean "public", default: true, null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tone"
    t.string "format"
    t.string "audience"
    t.string "length"
    t.index ["author_id"], name: "index_prompt_templates_on_author_id"
    t.index ["category"], name: "index_prompt_templates_on_category"
    t.index ["public"], name: "index_prompt_templates_on_public"
  end

  create_table "prompts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "idea"
    t.text "generated_prompt"
    t.string "category"
    t.string "tone"
    t.string "format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_prompts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "prompt_templates", "users", column: "author_id", on_delete: :nullify
  add_foreign_key "prompts", "users"
end
