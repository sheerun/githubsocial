class SessionsController < ActionController::Base
  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)

    session[:user_id] = @user.id

    redirect_to '/'
  end

  def destroy
    reset_session

    redirect_to '/'
  end

  def failure
    flash[:alert] = failure_message

    redirect_to '/'
  end

  protected

  def failure_message
    exception = env["omniauth.error"]
    error   = exception.error_reason if exception.respond_to?(:error_reason)
    error ||= exception.error        if exception.respond_to?(:error)
    error ||= env["omniauth.error.type"].to_s
    error.to_s.humanize if error
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
