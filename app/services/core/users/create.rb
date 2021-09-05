# frozen_string_literal: true

module Core
  module Users
    class Create < ApplicationService
      step :save
      dependency :users_repo, User

      private

      def save(attrs)
        user = users_repo.create!(**attrs)
        { user: user }
      rescue ActiveRecord::RecordNotUnique
        raise FailureError, identity_number: :already_exists
      end
    end
  end
end
