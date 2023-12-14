class UsersController < ApplicationController
  before_action :set_user, only: [:view_salary_slip_details, :send_salary_slip_email]

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
    @selected_month = params[:month].to_i if params[:month].present?
  end

  def view_salary_slip_details
    year = Date.current.year
    month = params[:month].to_i || 12
    @holiday_service = HolidayService.new
    @salary_details = calculate_salary(@user.id, year, month)
  end

  def send_salary_slip_email
    salary_details = calculate_salary(@user.id)
    SalaryMailer.send_salary_slip(@user, salary_details).deliver_now

    flash[:notice] = 'Salary slip sent successfully!'
    redirect_to salary_slip_users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def calculate_salary(user_id, year, month)
    user = User.find(user_id)
    working_days_in_month = 0
    employee_working_days = 0
    leave_days = 0

    (1..Time.days_in_month(month, year)).each do |day|
      date = Date.new(year, month, day)
      is_weekend = [0, 6].include?(date.wday)
      is_holiday = HolidayService.new.holiday?(date)

      if !is_weekend && !is_holiday
        working_days_in_month += 1

        attendance = Attendance.find_by(user_id: user_id, date: date.beginning_of_day..date.end_of_day)
        working_hours = calculate_hrs(attendance.time_in, attendance.time_out)
        if attendance&.time_in.present? && attendance&.time_out.present? && attendance.present? && working_hours >= 9
          employee_working_days += 1
        elsif working_hours < 9
            employee_working_days += 0.5
        else
          leave_days += 1
        end
      end
    end

    current_salary = user.current_salary.to_i
    one_day_salary = working_days_in_month.zero? ? 0 : current_salary / working_days_in_month.to_f
    net_salary = one_day_salary * employee_working_days

    {
      working_days_in_month: working_days_in_month,
      employee_working_days: employee_working_days,
      leave_days: leave_days,
      one_day_salary: one_day_salary,
      net_salary: net_salary
    }
  end

  def calculate_hrs(time_in, time_out)
    time_difference_seconds = (time_out - time_in).to_i
    hours_worked = time_difference_seconds / 3600.0
  end

  def user_params
    params.require(:user).permit(:name, :employee_code, :email, :password, :current_salary, :is_hr)
  end
end
