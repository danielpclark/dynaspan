# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: %i[show update] do
    get :playground, on: :member
  end
  root 'users#index'
end
