# frozen_string_literal: true

module Core
  module Reports
    class SumDepositByCurrencies < ApplicationService
      step :base_scope
      step :report
      dependency :deposit_events_repo, DepositEvent

      private

      def base_scope(from: 1.months.ago, to: Time.current, user_id: nil)
        base_scope =
          if user_id
            deposit_events_repo.where(user_id: user_id)
          else
            deposit_events_repo.joins(:events).where(events: { created_at: from..to })
          end
        { scope: base_scope }
      end

      def report(scope:)
        scope
          .select('currency, sum(amount) as sum, count(*) as count')
          .group(:currency)
          .map { |object| { object.currency => object.sum, :count => object.count } }
      end
    end
  end
end
