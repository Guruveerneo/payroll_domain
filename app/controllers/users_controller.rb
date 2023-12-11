class UsersController < ApplicationController

	def new
    @user = User.new
      render shared: 'application'
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to dashboard_path, notice: 'Employee created successfully!'
    else
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :employee_code, :email, :password, :current_salary, :is_hr)
  end
end
