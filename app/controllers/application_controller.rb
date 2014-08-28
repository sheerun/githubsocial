class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
  end

  def related
  end

  helper_method :application_metadata


  def default_repos
    %w(
      sass/sass
      JuliaLang/julia
      sleuthkit/sleuthkit
      plataformatec/devise
      kiwi-bdd/Kiwi
      mitchellh/vagrant
      jacomyal/sigma.js
      facebook/react
      symfony/symfony
      elixir-lang/elixir
      janl/mustache.js
      django/django
    ).map do |full_name|
      owner, name = full_name.split('/')
      Repo.find_by(name: name, owner: owner).as_json(extended: true)
    end
  end

  def application_metadata
    data = {
      env: Rails.env,
      current_user: current_user.as_json(extended: true),
      default_repos: default_repos
    }

    %Q%
      <script type="text/javascript">
        window.Rails = #{data.to_json}
      </script>
    %.html_safe
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end
