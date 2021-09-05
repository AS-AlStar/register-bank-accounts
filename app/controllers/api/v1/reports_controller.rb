# frozen_string_literal: true

module API
  module V1
    class ReportsController < BaseController
      def sum_deposit_by_currencies
        result = Web::Reports::SumDepositByCurrencies.new.call(params: sum_deposit_by_currencies_params)

        if result.success?
          render json: result.data.as_json, status: :ok
        else
          render json: result.data.as_json, status: :unprocessable_entity
        end
      end

      def sum_account_balance_by_currencies
        result = Web::Reports::SumAccountBalanceByCurrencies.new.call(params: params.permit(:tags))

        if result.success?
          render json: result.data.as_json, status: :ok
        else
          render json: result.data.as_json, status: :unprocessable_entity
        end
      end

      def average_max_min_transfer
        result = Web::Reports::AverageMaxMinTransfer.new.call(params: average_max_min_transfer_params)

        if result.success?
          render json: result.data.as_json, status: :ok
        else
          render json: result.data.as_json, status: :unprocessable_entity
        end
      end

      def sum_deposit_by_currencies_params
        params.permit(:from, :to, :user_id)
      end

      def average_max_min_transfer_params
        params.permit(:from, :to, :tags)
      end
    end
  end
end
