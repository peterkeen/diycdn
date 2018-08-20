require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :admin do
    mount Sidekiq::Web => '/sidekiq'

    resources :proxies
    resources :sites

    root to: "proxies#index"
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
