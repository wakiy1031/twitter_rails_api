# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'users', controllers: {
        registrations: 'api/v1/auth/registrations',
        confirmations: 'api/v1/auth/confirmations'
      }

      resources :tweets, only: %i[create show], controller: 'posts'

      post 'images', to: 'posts#upload_images'

      namespace :auth do
        resources :sessions, only: %i[index]
      end
    end
  end
end
