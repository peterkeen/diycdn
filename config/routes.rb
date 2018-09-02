require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["ADMIN_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["ADMIN_PASSWORD"]))
end if Rails.env.production?
  
  namespace :admin do
    mount Sidekiq::Web => '/sidekiq'

    resources :proxies do
      collection do
        get :force_setup
      end
    end
    resources :sites

    root to: "proxies#index"
  end

  resources :certificates, only: [:index]
  resources :configurations, only: [:index]

  get '/setup' => 'scripts#setup'
  get '/update' => 'scripts#update'
end
