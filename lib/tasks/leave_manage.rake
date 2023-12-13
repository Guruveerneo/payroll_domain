namespace :leave_manage do
  desc "Update leaves for employees"
  task update_leaves: :environment do
    # Set the date range for the previous month
    today = Date.today
    start_date = (today - 1.months).beginning_of_month
    end_date = (today - 1.month).end_of_month.end_of_day

    # Find the user with the specified employee code
    employee_code_to_manage = "NS6"
    user = User.find_by(employee_code: employee_code_to_manage)

    if user.present?
      # Calculate the monthly leave allowance for the employee (1.5 days)
      monthly_leave_allowance = 1.5

      # Calculate the total leave days taken by the employee in the specified date range
      leave_days_taken = Attendance.where(user_id: user.id, date: start_date..end_date).where("CAST(time_in AS TIME) = '00:00:00' AND CAST(time_out AS TIME) = '00:00:00'").count

      # Calculate the remaining leave balance
      remaining_leave_balance = monthly_leave_allowance - leave_days_taken

      puts "Leave balance for #{user.name} (#{start_date.strftime('%B %Y')}): #{remaining_leave_balance} days"

      # You can perform further actions based on the remaining leave balance
      # For example, you might want to update a leave balance field in the user model
      # user.update(leave_balance: remaining_leave_balance)
    else
      puts "User with employee code #{employee_code_to_manage} not found."
    end
  end
end


