class AddOmniauthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :provider, :string unless column_exists?(:users, :provider)
    add_column :users, :uid, :string unless column_exists?(:users, :uid)
    add_index :users, [:provider, :uid], unique: true, name: 'index_users_on_provider_and_uid'
  end
end
