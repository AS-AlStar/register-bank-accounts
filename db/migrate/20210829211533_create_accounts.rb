# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.string :currency, null: false
      t.decimal :balance, null: false
      t.bigint :user_id, null: false

      t.timestamps null: false
    end

    add_index :accounts, %i[user_id currency], unique: true
    add_foreign_key :accounts, :users
  end
end
