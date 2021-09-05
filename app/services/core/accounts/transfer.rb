# frozen_string_literal: true

module Core
  module Accounts
    class Transfer < ApplicationService
      step :find_producer_account
      step :find_consumer_account
      step :transfer
      step :log_event

      dependency :accounts_repo, Account
      dependency :accounts_lock, Account.method(:lock)
      dependency :find_account, Account.method(:find_by_identity_number_and_currency)
      dependency :users_repo, User
      dependency :create_account, ::Core::Accounts::Create.new
      dependency :create_transfer_event, ::Core::Events::Transfer::Create.new

      private

      def find_producer_account(**attrs)
        account = find_account.call(attrs.fetch(:identity_number_producer), attrs.fetch(:currency))

        if account.present?
          { attrs: attrs, producer: account }
        else
          raise FailureError, { user: :producer_not_found }
        end
      end

      def find_consumer_account(attrs:, **context)
        identity_number = attrs.fetch(:identity_number_consumer)
        currency = attrs.fetch(:currency)
        amount = attrs.fetch(:amount)
        account = find_account.call(identity_number, currency)
        return context.merge(amount: amount, consumer: account) if account.present?

        result = create_account.call(identity_number: identity_number, currency: currency)
        if result.success?
          context.merge(amount: amount, consumer: result.data.fetch(:account))
        else
          raise FailureError, { user: :consumer_not_found }
        end
      end

      def transfer(amount:, producer:, consumer:, **)
        ActiveRecord::Base.transaction do
          accounts_lock.call(producer, consumer)
          producer.reload
          if producer.balance >= amount
            producer.decrement!(:balance, amount)
            consumer.increment!(:balance, amount)
          else
            raise FailureError, { producer: :not_enough_money }
          end
        end
        { amount: amount, producer: producer, consumer: consumer }
      end

      def log_event(amount:, producer:, consumer:)
        create_transfer_event.call(amount: amount, producer: producer, consumer: consumer)
        { producer: producer, consumer: consumer }
      end
    end
  end
end
