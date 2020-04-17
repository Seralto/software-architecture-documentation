# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  namespace :api do
    namespace :v1 do
      get 'hierarchies', to: 'hierarchies#index'
    end
  end
end
