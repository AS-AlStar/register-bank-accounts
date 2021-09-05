# frozen_string_literal: true

module Core
  module Events
    module Transfer
      class Create < ApplicationService
        step :save
        dependency :transfer_events_repo, TransferEvent
        dependency :events_repo, Event

        private

        def save(amount:, producer:, consumer:)
          deposit_event = transfer_events_repo.create!(
            producer_id: producer.user_id,
            consumer_id: consumer.user_id,
            currency: producer.currency,
            amount: amount
          )
          events_repo.create!(eventable_id: deposit_event.id, eventable_type: deposit_event.class.name.to_s)
          { deposit_event: deposit_event }
        end
      end
    end
  end
end
