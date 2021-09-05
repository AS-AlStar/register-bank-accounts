# frozen_string_literal: true

module Core
  module Accounts
    class Deposit < ApplicationService
      step :find_user
      step :find_or_create_account
      step :deposit
      step :log_event

      dependency :create_account, ::Core::Accounts::Create.new
      dependency :create_deposit_event, ::Core::Events::Deposit::Create.new
      dependency :account_repo, Account
      dependency :users_repo, User

      private

      def find_user(identity_number:, **context)
        user = users_repo.find_by(identity_number: identity_number)
        if user.present?
          context.merge(user: user)
        else
          raise FailureError, { user: :not_found }
        end
      end

      def find_or_create_account(user:, **context)
        currency = context.fetch(:currency)
        amount = context.fetch(:amount)
        account = account_repo.find_by(user: user, currency: currency)
        return { amount: amount, account: account } if account.present?

        result = create_account.call(
          user: user,
          currency: currency
        )
        if result.success?
          { amount: amount, account: result.data.fetch(:account) }
        else
          find_or_create_account(user: user, **context)
        end
      end

      def deposit(amount:, account:, **)
        account.increment!(:balance, BigDecimal(amount))
        { account: account, amount: amount }
      end

      def log_event(amount:, account:)
        create_deposit_event.call(amount: amount, account: account)
        { account: account }
      end
    end
  end
end
