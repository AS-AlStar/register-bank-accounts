# frozen_string_literal: true

module Core
  module Reports
    class SumAccountBalanceByCurrencies < ApplicationService
      step :base_scope
      step :report
      dependency :accounts_repo, Account

      private

      def base_scope(tags: [])
        return { scope: accounts_repo } if tags.empty?

        { scope: accounts_repo.joins(user: [:tags]).where(tags: { name: tags }) }
      end

      def report(scope:)
        select_columns = 'currency, sum(balance) as sum'
        # SOLUTION #1 - return all records
        scope.select(select_columns).group(:currency)
             .each_with_object({}) { |object, result| result[object.currency] = object.sum }

        # SOLUTION #2 - read with batch
        # result_rows = []
        # scope.find_in_batches(batch_size: 20_000) do |batch|
        #   account_ids = batch.map(&:id)
        #   result_rows += accounts_repo.select(select_columns).where(id: account_ids).group(:currency)
        # end
        # group_by_currencies = result_rows.group_by(&:currency).to_h
        # group_by_currencies.each_with_object({}) do |object, result|
        #   currency, rows = object
        #   result[currency] = rows.map(&:sum).sum
        # end
      end
    end
  end
end
