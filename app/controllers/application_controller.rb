class ApplicationController < ActionController::Base
	before_action :set_current_user

  private

  def set_current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

#   module AttendancesHelper
    
#   def calculate_hours_worked(time_in, time_out)
#     return 'N/A' if time_in.nil? || time_out.nil?

#     hours_worked = ((time_out - time_in) / 3600).to_i
#     "#{hours_worked} hours"
#   end
# end


end
