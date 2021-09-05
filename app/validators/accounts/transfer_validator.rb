# frozen_string_literal: true

module Accounts
  class TransferValidator < ApplicationValidator
    attribute :identity_number_producer, String
    attribute :identity_number_consumer, String
    attribute :amount, String
    attribute :currency, String

    validates :currency, presence: true
    validate :currency_code
    validates :identity_number_producer, presence: true
    validates :identity_number_consumer, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }

    def attributes
      original = super
      original.merge(amount: BigDecimal(original.fetch(:amount)))
    end
  end
end
