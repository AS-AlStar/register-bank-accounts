# frozen_string_literal: true

class TransferEvent < ApplicationRecord
  has_many :events, as: :eventable
end
