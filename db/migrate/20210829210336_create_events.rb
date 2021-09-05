# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :eventable_type, null: false
      t.bigint :eventable_id, null: false
      t.datetime :created_at, null: false
    end

    add_index :events, %i[eventable_id eventable_type], unique: true
  end
end
