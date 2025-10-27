class RenamePasswordDigestToEncryptedPassword < ActiveRecord::Migration[8.0]
    def change
      # If password_digest exists and encrypted_password doesn't, rename it.
      if column_exists?(:users, :password_digest) && !column_exists?(:users, :encrypted_password)
        reversible do |dir|
          dir.up   { rename_column :users, :password_digest, :encrypted_password }
          dir.down { rename_column :users, :encrypted_password, :password_digest }
        end
  
        # Devise expects non-null + default "" for encrypted_password
        change_column_default :users, :encrypted_password, "" unless column_default(:users, :encrypted_password) == ""
        change_column_null :users, :encrypted_password, false, "" unless column_null?(:users, :encrypted_password) == false
      else
        # If encrypted_password missing, add it in a safe way (won't clobber existing data)
        unless column_exists?(:users, :encrypted_password)
          add_column :users, :encrypted_password, :string, null: false, default: ""
        end
  
        # ensure the constraints
        change_column_default :users, :encrypted_password, "" unless column_default(:users, :encrypted_password) == ""
        change_column_null :users, :encrypted_password, false unless column_null?(:users, :encrypted_password) == false
      end
  
      # Add Devise-related columns/indexes if missing (harmless if already present)
      unless column_exists?(:users, :reset_password_token)
        add_column :users, :reset_password_token, :string
        add_index :users, :reset_password_token, unique: true
      end
  
      unless column_exists?(:users, :remember_created_at)
        add_column :users, :remember_created_at, :datetime
      end
    end
  
    private
  
    # helper methods for migration to probe column defaults/null - these are safe
    def column_default(table, column)
      c = columns(table).find { |col| col.name == column.to_s }
      c&.default
    end
  
    def column_null?(table, column)
      c = columns(table).find { |col| col.name == column.to_s }
      c ? c.null : nil
    end
  end
  