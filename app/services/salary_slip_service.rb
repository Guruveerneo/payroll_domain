class SalarySlipService
  def initialize(user)
    @user = user
  end

  def calculate_salary(year, month)
    working_days_in_month = 0
    employee_working_days = 0
    leave_days = 0

    (1..Time.days_in_month(month, year)).each do |day|
      date = Date.new(year, month, day)
      is_weekend = [0, 6].include?(date.wday)
      is_holiday = HolidayService.new.holiday?(date)

      if !is_weekend && !is_holiday
        working_days_in_month += 1

        attendance = Attendance.find_by(user_id: @user.id, date: date.beginning_of_day..date.end_of_day)
        working_hours = calculate_hrs(attendance&.time_in, attendance&.time_out)
        
        if attendance&.present? && working_hours >= 9
          employee_working_days += 1
        elsif attendance&.present? && working_hours < 9
          employee_working_days += 0.5
        else
          leave_days += 1
        end
      end
    end

    current_salary = @user.current_salary.to_i
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

  def send_salary_slip_email
    salary_details = calculate_salary(Date.current.year, Date.current.month)
    SalaryMailer.send_salary_slip(@user, salary_details).deliver_now
    # Note: You might want to handle errors and flash messages in the controller
  end

  private

  def calculate_hrs(time_in, time_out)
    return 0 if time_in.nil? || time_out.nil?

    time_difference_seconds = (time_out - time_in).to_i
    hours_worked = time_difference_seconds / 3600.0
  end
end
