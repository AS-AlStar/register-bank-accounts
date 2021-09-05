# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user, inverse_of: :accounts
  scope :with_currency, ->(currency) { where(currency: currency) }

  def self.find_by_identity_number_and_currency(identity_number, currency)
    joins(:user).with_currency(currency).find_by(users: { identity_number: identity_number })
  end

  def self.lock(*accounts)
    where(id: accounts.map(&:id)).lock.load
  end
end
