class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index

  end

  helper_method :application_metadata

  def application_metadata
    data = {
      env: Rails.env,
      current_user: current_user.as_json(extended: true)
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
