# frozen_string_literal: true

class CreateTransferEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :transfer_events do |t|
      t.string :currency, null: false
      t.decimal :amount, null: false
      t.bigint :producer_id, null: false
      t.bigint :consumer_id, null: false
    end
  end
end
