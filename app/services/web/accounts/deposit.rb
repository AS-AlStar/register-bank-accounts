# frozen_string_literal: true

module Web
  module Accounts
    class Deposit < ApplicationService
      step :validate
      step :deposit

      dependency :validator, ::Accounts::DepositValidator
      dependency :proccess_deposit, ::Core::Accounts::Deposit.new

      private

      def validate(params:, **context)
        result = validator.call(params)

        if result.success?
          context.merge(result.data)
        else
          raise FailureError, result.data
        end
      end

      def deposit(**attrs)
        result = proccess_deposit.call(**attrs)

        if result.success?
          { account: result.data.fetch(:account) }
        else
          raise FailureError, result.data
        end
      end
    end
  end
end
