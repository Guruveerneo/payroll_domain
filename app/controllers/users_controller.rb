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
    user_id = params[:id]
    year = 2023
    month = 12
    @holiday_service = HolidayService.new
    @salary_details = calculate_salary(user_id, year, month)
    # start_date = Date.today.beginning_of_month
    # end_date = Date.today.end_of_month.end_of_day
    # @attendance_data = @user.attendances.where(date: start_date..end_date)
    # @salary_details = calculate_salary(@user, @attendance_data)
  end

  def send_salary_slip_email
    user = User.find(params[:user_id])
    salary_details = calculate_salary(user)
    SalaryMailer.send_salary_slip(user, salary_details).deliver_now

    flash[:notice] = 'Salary slip sent successfully!'
    redirect_to salary_slip_users_path
  end

  private

#   def calculate_salary(user, attendance_data)
#     current_month = Date.today.month
#     last_month = Date.today.prev_month.month
#     start_date = Date.new(Date.today.year, last_month, 1).beginning_of_month
#     end_date = Date.new(Date.today.year, last_month, -1).end_of_month.end_of_day

#     attendance_data = user.attendances.where(date: start_date..end_date)

#     # total_working_hours = attendance_data.sum(&:total_working_hours)
#     base_salary = user.current_salary.to_i

#     working_days_in_month = Attendance.where("EXTRACT(MONTH FROM date) = ? AND EXTRACT(DAY FROM date) NOT IN (?)", Date.parse('November').month, [ 4, 5, 11, 12, 14, 18, 19, 25, 26]).count
#     leave_days = Attendance.where("time_in::time = '00:00:00' AND time_out::time = '00:00:00'").distinct.count(:date)
#     employee_working_days = working_days_in_month - leave_days

#     current_salary = user.current_salary.to_i
#     one_day_salary = current_salary / working_days_in_month.to_f
#     net_salary = employee_working_days*one_day_salary

#     {
#       working_days_in_month: working_days_in_month,
#       employee_working_days: employee_working_days,
#       leave_days: leave_days,
#       one_day_salary: one_day_salary,
#       leaves_deduction: leave_days * one_day_salary,
#       net_salary: net_salary
#     # Add more calculations as needed
#   }
# end

  def calculate_salary(user_id, year, month)
  user = User.find(user_id)
  working_days_in_month = 0
  employee_working_days = 0
  leave_days = 0

  # Iterate through each day of the month
  (1..Time.days_in_month(month, year)).each do |day|
    date = Date.new(year, month, day)

    is_weekend = [0, 6].include?(date.wday)
    is_holiday = @holiday_service.holiday?(date)

    # Check if it's a working day (exclude weekends and fixed holidays)
    if !is_weekend && !is_holiday
      working_days_in_month += 1

      # Check if the user has attendance data for the day
      attendance = Attendance.find_by(user_id: user_id, date: date)
      if attendance.present? && attendance.time_in.present? && attendance.time_out.present?
        # If both time_in and time_out are present, it's a full working day
        employee_working_days += 1
      else
        # If either time_in or time_out is absent, consider it as leave
        leave_days += 1
      end
    end
  end

  # Calculate one day salary (assuming monthly salary is stored in cents)
  current_salary = user.current_salary.to_i
  one_day_salary = working_days_in_month.zero? ? 0 : current_salary / working_days_in_month.to_f

  # Calculate net salary
  net_salary = one_day_salary * employee_working_days

  {
    working_days_in_month: working_days_in_month,
    employee_working_days: employee_working_days,
    leave_days: leave_days,
    one_day_salary: one_day_salary,
    net_salary: net_salary
  }
end

  def user_params
    params.require(:user).permit(:name, :employee_code, :email, :password, :current_salary, :is_hr)
  end
end