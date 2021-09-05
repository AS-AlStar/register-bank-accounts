# frozen_string_literal: true

require 'rails_helper'

describe Web::Accounts::Transfer do
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
      params: {
        identity_number_producer: identity_number_producer,
        identity_number_consumer: identity_number_consumer,
        currency: currency,
        amount: amount
      }
    }
  end

  before do
    producer_account
    consumer_account
  end

  shared_examples :completes_successfully do
    it 'successful result' do
      expect(result.success?).to eq(true)
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

  context 'when valid params' do
    it_behaves_like :completes_successfully
  end

  context 'when invalid params' do
    context 'when identity_number_producer is nil' do
      let(:identity_number_producer) { nil }
      let(:error_data) { { identity_number_producer: ["can't be blank"] } }

      it_behaves_like :completes_fail
    end

    context 'when identity_number_consumer is nil' do
      let(:identity_number_consumer) { nil }
      let(:error_data) { { identity_number_consumer: ["can't be blank"] } }

      it_behaves_like :completes_fail
    end

    context 'when currency invalid' do
      let(:currency) { 'invalid' }
      let(:error_data) { { currency: ['Unknown currency or invalid format'] } }

      it_behaves_like :completes_fail
    end

    context 'when amount is negative' do
      let(:amount) { BigDecimal('-100') }
      let(:error_data) { { amount: ['must be greater than 0'] } }

      it_behaves_like :completes_fail
    end

    context 'when invalid 2 and more params' do
      let(:amount) { BigDecimal('-100') }
      let(:currency) { 'invalid' }

      let(:error_data) do
        { currency: ['Unknown currency or invalid format'], amount: ['must be greater than 0'] }
      end

      it_behaves_like :completes_fail
    end
  end
end
