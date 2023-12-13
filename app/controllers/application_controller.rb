class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def require_login
    unless current_user
      flash[:alert] = 'You must be logged in to access this page.'
      redirect_to new_session_path
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
