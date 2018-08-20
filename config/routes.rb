require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :admin do
    mount Sidekiq::Web => '/sidekiq'

    resources :proxies
    resources :sites

    root to: "proxies#index"
  end

  resources :certificates, only: [:index]
end
