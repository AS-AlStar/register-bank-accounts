# frozen_string_literal: true

module Reports
  class SumDepositByCurrenciesValidator < ApplicationValidator
    attribute :user_id, Integer
    attribute :from, String
    attribute :to, String

    validates :from, presence: true
    validates :to, presence: true
    validate :check_from
    validate :check_to

    def check_from
      return if errors[:from].any?

      DateTime.parse(from)
    rescue
      errors.add :from, 'Invalid format'
    end

    def check_to
      return if errors[:to].any?

      DateTime.parse(to)
    rescue
      errors.add :to, 'Invalid format'
    end
  end
end
