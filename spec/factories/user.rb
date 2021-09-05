# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    identity_number { SecureRandom.uuid }
    first_name { 'Alex' }
    last_name { 'Star' }
  end
end
