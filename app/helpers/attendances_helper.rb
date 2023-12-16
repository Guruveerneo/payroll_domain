module AttendancesHelper
  def calculate_working_hours(attendance)
    return nil unless attendance.time_in && attendance.time_out

    total_seconds = (attendance.time_out - attendance.time_in).to_i

    hours, remainder = total_seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)

    # Format the total working hours as HH:MM:SS
    "#{format('%02d', hours)}:#{format('%02d', minutes)}:#{format('%02d', seconds)}"
  end
end
