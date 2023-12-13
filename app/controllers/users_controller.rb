class UsersController < ApplicationController

	def new
    @user = User.new
      render shared: 'application'
  end

  def index
  @users = User.all

end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to dashboard_path, notice: 'Employee created successfully!'
    else
      render 'new'
    end
  end

  def salary_slip
    @users = User.all
    # @user = User.find(params[:id])
    # Add logic to calculate salary slip details if needed
  end

  def view_salary_slip_details

      @user = User.find(params[:id])
      @salary_details = {
      total_working_hours: 176,
      leaves_taken: 1,
      leaves_balance: 3.5,
      leaves_deduction: 500
    # Add more details as needed
  }
    # Add logic to retrieve additional salary slip details if needed
  end

  def send_salary_slip_email
    user = User.find(params[:user_id])
    salary_details = {}  # You may need to set this up based on your requirements
    SalaryMailer.send_salary_slip(user, salary_details).deliver_now

    flash[:notice] = 'Salary slip sent successfully!'
    redirect_to salary_slip_users_path
  end



  private

    def calculate_salary(user)
      total_working_hours = user.attendances.sum(&:total_working_hours)
      base_salary = user.current_salary.to_i
      leaves_taken = user.attendances.where('extract(month from date) = ?', Time.now.month).count
      leaves_provided_per_month = 1.5
      leaves_balance = leaves_provided_per_month * Time.now.month
      leaves_deduction = [leaves_taken - leaves_provided_per_month, 0].max

      # Check if total working days are less than 22 and leave is available
      if (total_working_hours / 8) < 22 && leaves_balance > 0
        leaves_deduction = [leaves_deduction, leaves_balance].min
      else
        leaves_deduction = 0
      end

      leave_deduction_amount = leaves_deduction * (base_salary / 30.0)  # Assuming 30 days in a month
      half_day_deduction = user.attendances.any? { |attendance| attendance.total_working_hours < 9 } ? (base_salary / 2.0) : 0

      net_salary = base_salary - leave_deduction_amount - half_day_deduction

      {
        total_working_hours: total_working_hours,
        leaves_taken: leaves_taken,
        leaves_balance: leaves_balance,
        leaves_deduction: leaves_deduction,
        leave_deduction_amount: leave_deduction_amount,
        half_day_deduction: half_day_deduction,
        net_salary: net_salary
      }
    end


  def user_params
    params.require(:user).permit(:name, :employee_code, :email, :password, :current_salary, :is_hr)
  end
end
