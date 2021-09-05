# frozen_string_literal: true

class DepositEvent < ApplicationRecord
  has_many :events, as: :eventable
end
