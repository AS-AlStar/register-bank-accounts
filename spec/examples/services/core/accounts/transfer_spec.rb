# frozen_string_literal: true

require 'rails_helper'

describe Core::Accounts::Transfer do
  subject(:result) { described_class.new(**dependencies).call(**payload) }

  let(:dependencies) { {} }
  let(:amount) { BigDecimal('99.9') }
  let(:currency) { 'USD' }
  let(:producer) { create :user }
  let(:consumer) { create :user }
  let(:producer_account) { create :account, user: producer, balance: producer_balance, currency: producer_currency }
  let(:consumer_account) { create :account, user: consumer, balance: consumer_balance, currency: consumer_currency }
  let(:producer_currency) { currency }
  let(:consumer_currency) { currency }
  let(:producer_balance) { BigDecimal('100') }
  let(:consumer_balance) { BigDecimal('0') }
  let(:identity_number_producer) { producer.identity_number }
  let(:identity_number_consumer) { consumer.identity_number }
  let(:payload) do
    {
      identity_number_producer: identity_number_producer,
      identity_number_consumer: identity_number_consumer,
      currency: currency,
      amount: amount
    }
  end
  let(:transfer_event) { TransferEvent.last }

  before do
    producer_account
    consumer_account
  end

  shared_examples :completes_successfully do
    it 'successful result' do
      expect(result.success?).to eq(true)
    end

    it 'create transfer event' do
      expect { result }.to change { TransferEvent.count }.by(1)
      expect(transfer_event.amount).to eq(amount)
      expect(transfer_event.producer_id).to eq(producer.id)
      expect(transfer_event.consumer_id).to eq(consumer.id)
      expect(transfer_event.currency).to eq(currency)
    end

    it 'decrement producer' do
      expect { result }.to change { producer_account.reload.balance }.by(-amount)
    end

    it 'increment consumer' do
      expect { result }.to change { consumer_account.reload.balance }.by(amount)
    end
  end

  shared_examples :completes_fail do
    it 'fail result' do
      expect(result.success?).to eq(false)
    end

    it 'error code' do
      expect(result.data).to eq(error_data)
    end

    it 'producer balance not changed' do
      expect(producer_account.reload.balance).to eq(producer_balance)
    end

    it 'consumer balance not changed' do
      expect(consumer_account.reload.balance).to eq(consumer_balance)
    end
  end

  context 'when producer not found' do
    let(:identity_number_producer) { 'undefine_number' }
    let(:error_data) { { user: :producer_not_found } }

    it_behaves_like :completes_fail
  end

  context 'when consumer not found' do
    let(:identity_number_consumer) { 'undefine_number' }
    let(:error_data) { { user: :consumer_not_found } }

    it_behaves_like :completes_fail
  end

  context 'when producer has not enough money' do
    let(:producer_balance) { BigDecimal('0') }
    let(:error_data) { { producer: :not_enough_money } }

    it_behaves_like :completes_fail
  end

  context 'when producer has enough money' do
    let(:producer_balance) { amount }

    context 'when consumer has no money' do
      it_behaves_like :completes_successfully
    end

    context 'when consumer has some money' do
      let(:consumer_balance) { BigDecimal('100') }

      it_behaves_like :completes_successfully
    end
  end

  context 'when the same account is being charged simultaneously' do
    before do
      consumer_account2
    end

    let(:consumer2) { create :user }
    let(:consumer_account2) { create :account, user: consumer2, balance: consumer_balance, currency: consumer_currency }
    let(:payload2) do
      {
        identity_number_producer: identity_number_producer,
        identity_number_consumer: consumer2.identity_number,
        currency: currency,
        amount: amount
      }
    end

    specify 'creates one gift for some user', truncate: true do
      process = described_class.new(**dependencies)
      Parallel.each([payload, payload2], in_processes: 2) do |payload|
        process.call(**payload)
      end
      expect(producer_account.reload.balance).to eq(0.1)
      consumers_balance_sum = consumer_account.reload.balance + consumer_account2.reload.balance
      expect(consumers_balance_sum).to eq(amount)
    end
  end
end
