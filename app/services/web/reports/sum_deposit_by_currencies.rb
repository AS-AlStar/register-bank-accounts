# frozen_string_literal: true

module Web
  module Reports
    class SumDepositByCurrencies < ApplicationService
      step :validate
      step :find_user
      step :report

      dependency :validator, ::Reports::SumDepositByCurrenciesValidator
      dependency :users_repo, User

      private

      def validate(params:, **context)
        result = validator.call(params)

        if result.success?
          context.merge(attrs: result.data)
        else
          raise FailureError, result.data
        end
      end

      def find_user(attrs:, **)
        user_id = attrs.fetch(:user_id, nil)
        user = users_repo.find_by(id: user_id)
        raise FailureError, { user: :not_found } if user_id.present? && user.blank?

        { from: attrs.fetch(:from), to: attrs.fetch(:to), user_id: user_id }
      end

      def report(from:, to:, user_id:)
        result = Core::Reports::SumDepositByCurrencies.new.call(from: from, to: to, user_id: user_id)
        { report: result.data }
      end
    end
  end
end
