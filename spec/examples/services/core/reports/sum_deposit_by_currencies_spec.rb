# frozen_string_literal: true

require 'rails_helper'

describe Core::Reports::SumDepositByCurrencies do
  subject(:result) { described_class.new(**dependencies).call(**payload) }

  let(:dependencies) { {} }
  let(:payload) do
    {
      from: 1.week.ago,
      to: Time.current,
      user_id: nil
    }
  end
  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }

  def deposit(currency: 'USD', identity_number: nil, amount: 100)
    deposit_params = { currency: currency, identity_number: identity_number, amount: amount }
    Web::Accounts::Deposit.new.call(params: deposit_params)
  end

  shared_examples :completes_successfully do
    it 'success result' do
      data = result.data.sort_by { |el| el.keys.first }
      expect(result.success?).to eq(true)
      expect(data).to eq(expected_data)
    end
  end

  context 'when all deposits included in time range' do
    before do
      deposit(identity_number: user1.identity_number)
      deposit(identity_number: user1.identity_number, currency: 'EUR')
      deposit(identity_number: user2.identity_number, currency: 'RUB')
      deposit(identity_number: user3.identity_number)
      deposit(identity_number: user3.identity_number, currency: 'BYN')
    end

    let(:expected_data) do
      [
        { 'EUR' => BigDecimal('100'), :count => 1 },
        { 'USD' => BigDecimal('200'), :count => 2 },
        { 'RUB' => BigDecimal('100'), :count => 1 },
        { 'BYN' => BigDecimal('100'), :count => 1 }
      ].sort_by { |el| el.keys.first }
    end

    it_behaves_like :completes_successfully
  end

  context 'when one deposit is not included in the time range' do
    before do
      deposit(identity_number: user1.identity_number)
      deposit(identity_number: user1.identity_number, currency: 'EUR')
      deposit(identity_number: user2.identity_number, currency: 'RUB')
      deposit(identity_number: user3.identity_number)

      Timecop.freeze(5.months.ago) do
        deposit(identity_number: user3.identity_number, currency: 'BYN')
      end
    end

    let(:expected_data) do
      [
        { 'EUR' => BigDecimal('100'), :count => 1 },
        { 'USD' => BigDecimal('200'), :count => 2 },
        { 'RUB' => BigDecimal('100'), :count => 1 }
      ].sort_by { |el| el.keys.first }
    end

    it_behaves_like :completes_successfully

    context 'when filter by user is present' do
      let(:payload) do
        {
          from: 1.week.ago,
          to: Time.current,
          user_id: user1.id
        }
      end

      let(:expected_data) do
        [
          { 'EUR' => BigDecimal('100'), :count => 1 },
          { 'USD' => BigDecimal('100'), :count => 1 }
        ].sort_by { |el| el.keys.first }
      end

      it_behaves_like :completes_successfully
    end
  end
end
