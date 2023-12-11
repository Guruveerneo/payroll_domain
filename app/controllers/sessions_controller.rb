class SessionsController < ApplicationController
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
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = 'Logged out successfully!'
    redirect_to root_path

  end

    #  def create
  #   user = User.find_by(email: params[:email])
  #   if user && user.authenticate(params[:password])
  #     if user.is_hr?
  #       session[:user_id] = user.id
  #       redirect_to new_user_path, notice: 'Logged in successfully!'
  #     else
  #       flash.now[:alert] = 'You do not have HR access. Only HR can log in.'
  #       render 'new'
  #       # render partial: 'layouts/flash_messages'
  #     end
  #   else
  #     flash.now[:alert] = 'Invalid email or password.'
  #     render 'new'
  #     # render partial: 'layouts/flash_messages'
  #   end
  # end

end
