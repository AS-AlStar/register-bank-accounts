# frozen_string_literal: true

module Web
  module Reports
    class AverageMaxMinTransfer < ApplicationService
      step :validate
      step :report

      dependency :validator, ::Reports::AverageMaxMinTransferValidator

      private

      def validate(params:, **)
        result = validator.call(params)

        if result.success?
          {
            from: result.data.fetch(:from),
            to: result.data.fetch(:to),
            tags: result.data.fetch(:tags)
          }
        else
          raise FailureError, result.data
        end
      end

      def report(from:, to:, tags: [])
        result = Core::Reports::AverageMaxMinTransfer.new.call(from: from, to: to, tags: tags)
        { report: result.data }
      end
    end
  end
end
