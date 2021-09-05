# frozen_string_literal: true

module Users
  class Create < ApplicationService
    step :validate
    step :save

    dependency :validator, Users::CreateValidator
    dependency :users_repo, User

    private

    def validate(params:, **context)
      result = validator.call(params)

      if result.success?
        context.merge(attrs: result.data)
      else
        raise FailureError, result.data
      end
    end

    def save(attrs:, **)
      user = users_repo.create!(attrs)
      { user: user }
    rescue ActiveRecord::RecordNotUnique
      raise FailureError, identity_number: :already_exists
    end
  end
end
