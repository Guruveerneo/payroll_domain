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
    # Add logic to calculate salary slip details if needed
  end

 def view_salary_slip_details
    @user = User.find(params[:id])
    start_date = Date.today.beginning_of_month
    end_date = Date.today.end_of_month.end_of_day
    @attendance_data = @user.attendances.where(date: start_date..end_date)
    @salary_details = calculate_salary(@user, @attendance_data)
  end

  def send_salary_slip_email
    user = User.find(params[:user_id])
    salary_details = calculate_salary(user)
    SalaryMailer.send_salary_slip(user, salary_details).deliver_now

    flash[:notice] = 'Salary slip sent successfully!'
    redirect_to salary_slip_users_path
  end

  private

  def calculate_salary(user, attendance_data)
  current_month = Date.today.month
  last_month = Date.today.prev_month.month
  start_date = Date.new(Date.today.year, last_month, 1).beginning_of_month
  end_date = Date.new(Date.today.year, last_month, -1).end_of_month.end_of_day

  attendance_data = user.attendances.where(date: start_date..end_date)

  # total_working_hours = attendance_data.sum(&:total_working_hours)
  base_salary = user.current_salary.to_i

   working_days_in_month = Attendance.where("EXTRACT(MONTH FROM date) = ? AND EXTRACT(DAY FROM date) NOT IN (?)", Date.parse('November').month, [ 4, 5, 11, 12, 14, 18, 19, 25, 26]).count
  leave_days = Attendance.where("time_in::time = '00:00:00' AND time_out::time = '00:00:00'").distinct.count(:date)
  employee_working_days = working_days_in_month - leave_days

  current_salary = user.current_salary.to_i
  one_day_salary = current_salary / working_days_in_month.to_f
  net_salary = employee_working_days*one_day_salary

  {
    working_days_in_month: working_days_in_month,
    employee_working_days: employee_working_days,
    leave_days: leave_days,
    one_day_salary: one_day_salary,
    leaves_deduction: leave_days * one_day_salary,
    net_salary: net_salary
    # Add more calculations as needed
  }
end



  def user_params
    params.require(:user).permit(:name, :employee_code, :email, :password, :current_salary, :is_hr)
  end
end