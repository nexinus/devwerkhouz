class CreatePromptTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :prompt_templates do |t|
      t.string  :title,        null: false
      t.text    :prompt_text,  null: false
      t.string  :category,     null: false, default: "Other"
      t.integer :author_id,    index: true
      t.boolean :public,       null: false, default: true
      t.integer :likes_count,  null: false, default: 0
      t.timestamps
    end

    add_index :prompt_templates, :category
    add_foreign_key :prompt_templates, :users, column: :author_id, on_delete: :nullify
  end
end
