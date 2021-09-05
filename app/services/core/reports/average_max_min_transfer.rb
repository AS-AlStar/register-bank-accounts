# frozen_string_literal: true

module Core
  module Reports
    class AverageMaxMinTransfer < ApplicationService
      step :base_scope
      step :report
      dependency :transfer_events_repo, TransferEvent

      private

      def base_scope(from: 1.months.ago, to: Time.current, tags: [])
        scope = transfer_events_repo.joins(:events).where(events: { created_at: from..to })
        return { scope: scope } if tags.empty?

        user_ids_with_tags = User.joins(:tags).where(tags: { name: tags }).pluck(:id)
        scope = scope.where(producer_id: user_ids_with_tags)
        { scope: scope }
      end

      def report(scope:)
        select_columns = "transfer_events.currency, avg(transfer_events.amount) as avg,
                          min(transfer_events.amount) as min, max(transfer_events.amount) as max"
        relation_result = scope.select(select_columns).group(:currency)
        relation_result
          .each_with_object([]) do |object, result|
            result << { currency: object.currency, avg: object.avg, min: object.min, max: object.max }
          end
      end
    end
  end
end
