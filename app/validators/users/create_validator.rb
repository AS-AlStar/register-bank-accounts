# frozen_string_literal: true

module Users
  class CreateValidator < ApplicationValidator
    attribute :first_name, String
    attribute :last_name, String
    attribute :identity_number, String
    attribute :tags, Array[String]

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :identity_number, presence: true
    validates :tags, presence: true
  end
end
