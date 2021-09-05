# frozen_string_literal: true

module Accounts
  class CreateValidator < ApplicationValidator
    attribute :currency, String
    attribute :identity_number, String

    validates :currency, presence: true
    validate :currency_code
    validates :identity_number, presence: true
  end
end
