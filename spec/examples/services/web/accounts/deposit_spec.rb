# frozen_string_literal: true

require 'rails_helper'

describe Web::Accounts::Deposit do
  subject(:result) { described_class.new(**dependencies).call(**payload) }

  let(:dependencies) { {} }
  let(:amount) { BigDecimal('99.9') }
  let(:currency) { 'USD' }
  let(:user) { create :user }
  let(:account) { create :account, user: user, balance: account_balance, currency: account_currency }
  let(:account_currency) { currency }
  let(:account_balance) { BigDecimal('100') }
  let(:identity_number) { user.identity_number }

  let(:payload) do
    {
      params: {
        identity_number: identity_number,
        currency: currency,
        amount: amount
      }
    }
  end

  before do
    account
  end

  shared_examples :completes_successfully do
    it 'successful result' do
      expect(result.success?).to eq(true)
      expect(account.reload.balance).to eq(BigDecimal('199.9'))
    end
  end

  shared_examples :completes_fail do
    it 'fail result' do
      expect(result.success?).to eq(false)
    end

    it 'error code' do
      expect(result.data).to eq(error_data)
    end
  end

  context 'when valid params' do
    it_behaves_like :completes_successfully
  end

  context 'when invalid params' do
    context 'when identity_number is nil' do
      let(:identity_number) { nil }
      let(:error_data) { { identity_number: ["can't be blank"] } }

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
