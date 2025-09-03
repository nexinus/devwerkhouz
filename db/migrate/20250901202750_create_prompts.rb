class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :prompts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :idea
      t.text :generated_prompt
      t.string :category
      t.string :tone
      t.string :format

      t.timestamps
    end
  end
end
