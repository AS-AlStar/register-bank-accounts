# frozen_string_literal: true

class CreateDepositEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :deposit_events do |t|
      t.string :currency, null: false
      t.decimal :amount, null: false
      t.bigint :user_id, null: false
    end
  end
end
