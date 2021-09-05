# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_taggable_on :tags
  has_many :accounts, dependent: :destroy, inverse_of: :user
end
