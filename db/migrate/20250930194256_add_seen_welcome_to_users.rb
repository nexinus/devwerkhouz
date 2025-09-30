class AddSeenWelcomeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :seen_welcome, :boolean, default: false, null: false
  end
end
