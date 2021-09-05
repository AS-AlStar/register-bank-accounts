# frozen_string_literal: true

module Accounts
  class DepositValidator < ApplicationValidator
    attribute :identity_number, String
    attribute :amount, String
    attribute :currency, String

    validates :currency, presence: true
    validate :currency_code
    validates :identity_number, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }
  end
end
