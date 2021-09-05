# frozen_string_literal: true

module Core
  module Events
    module Deposit
      class Create < ApplicationService
        step :save
        dependency :deposit_events_repo, DepositEvent
        dependency :events_repo, Event

        private

        def save(account:, amount:)
          deposit_event = deposit_events_repo.create!(user_id: account.user_id, currency: account.currency,
                                                      amount: amount)
          events_repo.create!(eventable_id: deposit_event.id, eventable_type: deposit_event.class.name.to_s)
          { deposit_event: deposit_event }
        end
      end
    end
  end
end
