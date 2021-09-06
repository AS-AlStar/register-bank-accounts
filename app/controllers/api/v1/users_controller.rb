# frozen_string_literal: true

module API
  module V1
    class UsersController < BaseController
      def create
        result = Web::Users::Create.new.call(params: users_params)

        if result.success?
          render json: result.data.as_json, status: :ok
        else
          render json: result.data.as_json, status: :unprocessable_entity
        end
      end

      def users_params
        params.permit(:first_name, :last_name, :identity_number, tags: [])
      end
    end
  end
end
