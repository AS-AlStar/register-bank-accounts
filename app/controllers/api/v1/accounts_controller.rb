# frozen_string_literal: true

module API
  module V1
    class AccountsController < BaseController
      def create
        result = Web::Accounts::Create.new.call(params: create_params)

        if result.success?
          render json: result.data.as_json, status: :ok
        else
          render json: result.data.as_json, status: :unprocessable_entity
        end
      end

      def deposit
        result = Web::Accounts::Deposit.new.call(params: deposit_params)

        if result.success?
          render json: result.data.as_json, status: :ok
        else
          render json: result.data.as_json, status: :unprocessable_entity
        end
      end

      def transfer
        result = Web::Accounts::Transfer.new.call(params: transfer_params)

        if result.success?
          render json: result.data.as_json, status: :ok
        else
          render json: result.data.as_json, status: :unprocessable_entity
        end
      end

      private

      def deposit_params
        params.permit(:currency, :identity_number, :amount)
      end

      def create_params
        params.permit(:currency, :identity_number)
      end

      def transfer_params
        params.permit(:currency, :identity_number_producer, :identity_number_consumer, :amount)
      end
    end
  end
end
