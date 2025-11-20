# frozen_string_literal: true

class CreateApiKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :api_keys do |t|
      t.string :name, null: false
      t.string :key, null: false, index: { unique: true }
      t.text :description
      t.datetime :expires_at
      t.datetime :revoked_at
      t.datetime :last_used_at
      t.integer :usage_count, default: 0
      t.json :permissions, default: {}
      t.string :created_by_ip

      t.timestamps
    end

    add_index :api_keys, :expires_at
    add_index :api_keys, :revoked_at
  end
end
