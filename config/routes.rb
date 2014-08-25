Application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/auth/logout', to: 'sessions#destroy'

  get '/api' => 'api#index'
  get '/api/:owner/:name/related' => 'api#related_repos', constraints: {
    name: /[^\/]+/,
    owner: /[^\/]+/,
  }

  get '/api/*path' => 'api#not_found'

  match '(errors)/:status', to: 'errors#show',
    constraints: { status: /\d{3}/ },
    defaults: { status: '500' },
    via: :all

  root 'application#index'
end
