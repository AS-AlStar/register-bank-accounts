# frozen_string_literal: true

module Web
  module Reports
    class SumAccountBalanceByCurrencies < ApplicationService
      step :report

      private

      def report(params:, **)
        result = Core::Reports::SumAccountBalanceByCurrencies.new.call(tags: params.fetch(:tags, []))
        { report: result.data }
      end
    end
  end
end
