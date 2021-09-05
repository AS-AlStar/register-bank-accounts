# frozen_string_literal: true

# Create users
10.times do |i|
  users_params = {
    first_name: "Ivan#{i}",
    last_name: "Ivanov#{i}",
    identity_number: SecureRandom.uuid,
    tags: ["t", "a", "g" "s"]
  }
  Web::Users::Create.new.call(params: users_params)
end

identity_numbers = User.pluck(:identity_number)
amount = [10, 20, 30, 40, 50, 60, 70, 80]
currencies = %w[USD EUR BYN RUB]

# Create accounts
10.times do
  create_params = { currency: currencies.sample, identity_number: identity_numbers.sample }
  Web::Accounts::Create.new.call(params: create_params)
end

# Create deposits
10.times do
  deposit_params = {
    currency: currencies.sample,
    identity_number: identity_numbers.sample,
    amount: amount.sample,
  }
  Web::Accounts::Deposit.new.call(params: deposit_params)
end

# Create transfers
10.times do
  payload = {
    identity_number_producer: identity_numbers.sample,
    identity_number_consumer: identity_numbers.sample,
    currency: currencies.sample,
    amount: amount.sample
  }
  ::Web::Accounts::Transfer.new.call(params: payload)
end
