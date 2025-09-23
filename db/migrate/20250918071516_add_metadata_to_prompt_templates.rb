class AddMetadataToPromptTemplates < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:prompt_templates, :tone)
      add_column :prompt_templates, :tone, :string
    end

    unless column_exists?(:prompt_templates, :format)
      add_column :prompt_templates, :format, :string
    end

    unless column_exists?(:prompt_templates, :audience)
      add_column :prompt_templates, :audience, :string
    end

    unless column_exists?(:prompt_templates, :length)
      add_column :prompt_templates, :length, :string
    end

    unless column_exists?(:prompt_templates, :public)
      add_column :prompt_templates, :public, :boolean, default: true, null: false
    end

    unless column_exists?(:prompt_templates, :likes_count)
      add_column :prompt_templates, :likes_count, :integer, default: 0, null: false
    end

    # Optionally add indexes if you will query by category/public often:
    unless index_exists?(:prompt_templates, :public)
      add_index :prompt_templates, :public
    end

    unless index_exists?(:prompt_templates, :category)
      add_index :prompt_templates, :category
    end
  end
end
