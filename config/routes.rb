Application.routes.draw do
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
  get '/*path' => 'application#index'
end
