# frozen_string_literal: true

module Web
  module Accounts
    class Create < ApplicationService
      step :validate
      step :find_user
      step :save

      dependency :validator, ::Accounts::CreateValidator
      dependency :account_repo, Account
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

      def find_user(attrs:, **)
        user = users_repo.find_by(identity_number: attrs.fetch(:identity_number))
        if user.present?
          { attrs: attrs, user: user }
        else
          raise FailureError, { user: :not_found }
        end
      end

      def save(attrs:, user:, **)
        account = Core::Accounts::Create.new.call(user: user, currency: attrs.fetch(:currency))
        { account: account.data.fetch(:account) }
      end
    end
  end
end
