# frozen_string_literal: true

module Web
  module Accounts
    class Transfer < ApplicationService
      step :validate
      step :transfer
      dependency :validator, ::Accounts::TransferValidator
      dependency :transfer_process, ::Core::Accounts::Transfer.new

      private

      def validate(params:, **context)
        result = validator.call(params)

        if result.success?
          context.merge(result.data)
        else
          raise FailureError, result.data
        end
      end

      def transfer(context)
        result = transfer_process.call(**context)

        if result.success?
          { producer: result.data.fetch(:producer), consumer: result.data.fetch(:consumer) }
        else
          raise FailureError, result.data
        end
      end
    end
  end
end
