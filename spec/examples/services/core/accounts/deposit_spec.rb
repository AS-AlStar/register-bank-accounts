# frozen_string_literal: true

require 'rails_helper'

describe Core::Accounts::Deposit do
  subject(:result) { described_class.new(**dependencies).call(**payload) }

  let(:dependencies) { {} }
  let(:amount) { BigDecimal('99.9') }
  let(:currency) { 'USD' }
  let(:user) { create :user }
  let(:account) { create :account, user: user, balance: user_balance, currency: user_currency }
  let(:user_currency) { currency }
  let(:user_balance) { BigDecimal('100') }
  let(:identity_number) { user.identity_number }
  let(:payload) do
    {
      identity_number: identity_number,
      currency: currency,
      amount: amount
    }
  end
  let(:deposit_event) { DepositEvent.last }

  before do
    account
  end

  shared_examples :completes_successfully do
    it 'successful result' do
      expect(result.success?).to eq(true)
    end

    it 'create deposit event' do
      expect { result }.to change { DepositEvent.count }.by(1)
      expect(deposit_event.amount).to eq(amount)
      expect(deposit_event.user_id).to eq(user.id)
      expect(deposit_event.currency).to eq(currency)
    end

    it 'increment balance' do
      expect { result }.to change { account.reload.balance }.by(amount)
    end
  end

  shared_examples :completes_fail do
    it 'fail result' do
      expect(result.success?).to eq(false)
    end

    it 'error code' do
      expect(result.data).to eq(error_data)
    end

    it 'user balance not changed' do
      expect(account.reload.balance).to eq(user_balance)
    end
  end

  context 'when user present' do
    it_behaves_like :completes_successfully
  end

  context 'when user not found' do
    let(:identity_number) { 'some identity_number' }
    let(:error_data) { { user: :not_found } }

    it_behaves_like :completes_fail
  end

  context 'when create account for currency' do
    let(:user_currency) { 'EUR' }

    it 'successful result' do
      expect(result.success?).to eq(true)
    end

    it 'create deposit event' do
      expect { result }.to change { DepositEvent.count }.by(1)
      expect(deposit_event.amount).to eq(amount)
      expect(deposit_event.user_id).to eq(user.id)
      expect(deposit_event.currency).to eq(currency)
    end

    specify 'increment balance' do
      result
      account = Account.last
      expect(account.balance).to eq(amount)
      expect(account.user_id).to eq(user.id)
      expect(account.currency).to eq(currency)
    end
  end
end
