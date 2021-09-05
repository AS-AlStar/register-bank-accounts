# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, format: "json" do
    namespace :v1 do
      resources :users, only: [:create]

      namespace :accounts do
        post :create
        post :deposit
        post :transfer
      end

      namespace :reports do
        post :sum_deposit_by_currencies
        post :sum_account_balance_by_currencies
        post :average_max_min_transfer
      end
    end
  end
end
