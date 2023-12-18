class SessionsController < ApplicationController
  before_action :require_login, except: [:new, :create]

	def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password]) && user.is_hr?
      session[:user_id] = user.id
      flash[:notice] = 'Logged in successfully!'
      redirect_to dashboard_path
    else
      flash[:alert] = 'Invalid email or password or you do not have HR access.'
      redirect_to new_session_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = 'Logged out successfully!'
    redirect_to root_path
  end
end
