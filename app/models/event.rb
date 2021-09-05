# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true
end
