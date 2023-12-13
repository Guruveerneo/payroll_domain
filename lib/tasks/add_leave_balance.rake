namespace :leave_balance do
  desc "Add 1.5 leave to every employee's leave_balance at the beginning of the month"

  task :add_monthly_leave_balance => :environment do
    # Get all users
    users = User.all

    # Add 1.5 leave to each user's leave_balance
    users.each do |user|
      # Set an initial leave_balance if not set
      user.leave_balance ||= 0.0
      user.leave_balance += 1.5
      user.save
    end
    puts "Monthly leave balance update completed!"
  end
end