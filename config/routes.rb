Application.routes.draw do
  root 'application#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/auth/logout', to: 'sessions#destroy'

  get '/api' => 'api#index'
  get '/api/default_repos' => 'api#default_repos'
  get '/api/:owner/:name/related' => 'api#related_repos', constraints: {
    name: /[^\/]+/,
    owner: /[^\/]+/,
  }

  get '/api/*path' => 'api#not_found'

  require 'sidekiq/web'
  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == [
      "admin", ENV['SIDEKIQ_PASSWORD'] || "password"
    ]
  end
  mount Sidekiq::Web => '/sidekiq'

  get '/:owner/:name/related' => 'application#index', constraints: {
    name: /[^\/]+/,
    owner: /[^\/]+/,
  }

  match '(errors)/:status', to: 'errors#show',
    constraints: { status: /\d{3}/ },
    defaults: { status: '500' },
    via: :all
end
