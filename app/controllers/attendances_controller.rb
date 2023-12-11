class AttendancesController < ApplicationController
  require 'chronic'
  include AttendancesHelper # Include the helper module
   
def new
  @attendance = Attendance.new
end

def create
  file = attendance_params[:file]

  if file.blank?
    flash[:alert] = 'Please select a file to import.'
    redirect_to new_attendance_path and return
  end

  begin
    spreadsheet = Roo::Spreadsheet.open(file.path)
  rescue Roo::Spreadsheet::UnknownFileType
    flash[:alert] = 'Invalid file format. Please upload a valid Excel file.'
    redirect_to new_attendance_path and return
  end

  header = spreadsheet.row(1)

  (2..spreadsheet.last_row).each do |i|
    row = Hash[[header, spreadsheet.row(i)].transpose]

    # Find the employee by employee_code

    user = User.find_by(employee_code: row['employee_code'])
    if user.present?
      attendance_data = {
        user_id: user.id,
        # date: parse_date(row['date']),
        time_in: parse_time(row['time_in'].to_i),
        time_out: parse_time(row['time_out'].to_i),
        present: row['present']
      }

      @attendance = Attendance.new(attendance_data)

      unless @attendance.save
        puts @attendance.errors.full_messages 
        flash[:alert] = 'An error occurred while importing the data.'
        redirect_to new_attendance_path and return
      end

       # Calculate salary, deduct leaves, and handle half-day salary
        calculate_and_deduct(user, @attendance)
    else
      flash[:alert] = "Employee with code #{row['employee_code']} not found."
      redirect_to new_attendance_path and return
    end
  end

  flash[:notice] = 'Attendance data imported successfully!'
  redirect_to attendances_path
end

# Add these methods after your existing methods
def calendar_view
  @attendances = Attendance.where(user_id: current_user.id) # Adjust as needed
end

# def list_view
#   # @attendances = Attendance.where(user_id: @current_user.id) # Adjust as needed
#    @attendances = Attendance.all
# end

def list_view
    @attendances = filter_attendances(params[:employee_code], params[:month], params[:year])
  end


  def calendar_view
  @attendances = Attendance.all # Fetch your attendances as needed
  @events = []

  @attendances.each do |attendance|
    @events << {
      title: calculate_working_hours(attendance),
      start: attendance.date, # Assuming date is the date of the attendance record
      allDay: true # Display as all-day event
    }
  end
end


private

# def filter_attendances(employee_code, month, year)
#     attendances = Attendance.all

#     attendances = attendances.where(user_id: User.where(employee_code: employee_code).pluck(:id)) if employee_code.present?

#     if month.present? && year.present?
#       start_date = Date.new(year.to_i, month.to_i, 1)
#       end_date = start_date.end_of_month
#       attendances = attendances.where(date: start_date..end_date)
#     end

#     attendances
#   end

def calculate_and_deduct(user, attendance)
    calculate_salary_for_user(user, attendance)
    deduct_leaves(user)
    deduct_half_day_salary(user, attendance)
  end

  def calculate_salary_for_user(user, attendance)
    base_salary = user.current_salary.to_i # Assuming current_salary is a string, convert to an integer

    # Leaves
    leaves_per_month = 1.5
    balance_leaves = user.leave_balance.to_f

    # Calculate leaves taken in the current month
    leaves_taken = user.attendances.where('extract(month from date) = ?', Time.now.month).count

    # Subtract balance leaves from leaves taken in the month
    leaves_to_deduct = [leaves_taken - balance_leaves, 0].max

    # Deduct leaves from the salary
    leaves_deduction = leaves_to_deduct * (base_salary / (30.0 * 8)) # Assuming 8 working hours per day

    # Half-day deduction
    attendances_today = user.attendances.where(date: Date.today.beginning_of_month..Date.today.end_of_month)
    half_day_deduction = attendances_today.any? { |a| a.total_working_hours < 9 } ? (base_salary / 2) : 0

    # Calculate final salary
    new_salary = base_salary - leaves_deduction - half_day_deduction

    # Update the user's salary attribute
    user.update(salary: new_salary)
  end

def filter_attendances(employee_code, month, year)
  attendances = Attendance.all

  attendances = attendances.where(user_id: User.where(employee_code: employee_code).pluck(:id)) if employee_code.present?

  if month.present? && year.present?
    start_date = Date.new(year.to_i, month.to_i, 1)
    end_date = start_date.end_of_month
    attendances = attendances.where("EXTRACT(MONTH FROM created_at) = ? AND EXTRACT(YEAR FROM created_at) = ?", start_date.month, start_date.year)
  end

  attendances
end

def parse_time(seconds)
  return nil if seconds.blank?

  hours, remainder = seconds.divmod(3600)
  minutes, seconds = remainder.divmod(60)

  # Format the time as HH:MM:SS
  formatted_time = "#{format('%02d', hours)}:#{format('%02d', minutes)}:#{format('%02d', seconds)}"

  # Return only the formatted time without the date
  Time.parse(formatted_time).strftime('%H:%M:%S')
end


	def attendance_params
	  params.require(:attendance).permit(:file)
	end

end
