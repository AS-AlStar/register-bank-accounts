# frozen_string_literal: true

module Core
  module Accounts
    class Create < ApplicationService
      step :find_user
      step :save
      dependency :accounts_repo, Account
      dependency :users_repo, User

      DEFAULT_BALANCE = BigDecimal('0.0').freeze

      private

      def find_user(user: nil, identity_number: nil, **context)
        user ||= users_repo.find_by(identity_number: identity_number)

        if user.present?
          context.merge(user: user)
        else
          raise FailureError, user: :not_found
        end
      end

      def save(currency:, user:)
        account = accounts_repo.create!(balance: DEFAULT_BALANCE, user: user, currency: currency)
        { account: account }
      rescue ActiveRecord::RecordNotUnique
        account = accounts_repo.find_by!(user: user, currency: currency)
        raise FailureError, account: account, error: :already_exists
      end
    end
  end
end
