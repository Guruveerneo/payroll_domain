class AttendanceFileService
  def initialize(file)
    @file = file
    @holiday_service = HolidayService.new
  end

  def process_file
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      process_attendance_row(row)
    end
  end

  private

  def open_spreadsheet
    Roo::Spreadsheet.open(@file.path)
  rescue Roo::Spreadsheet::UnknownFileType
    raise 'Invalid file format. Please upload a valid Excel file.'
  end

  # def process_attendance_row(row)
  #   user = User.find_by(employee_code: row['employee_code'])
  #   if user.present?
  #     attendance_data = {
  #       user_id: user.id,
  #       date: parse_date(row['date']),
  #       time_in: parse_time(row['time_in'].to_i),
  #       time_out: parse_time(row['time_out'].to_i),
  #       # present: row['present']
  #     }

  #     Attendance.create(attendance_data)
  #   else
  #     raise "Employee with code #{row['employee_code']} not found."
  #   end
  # end

  def process_attendance_row(row)
    user = User.find_by(employee_code: row['employee_code'])

    if user.present?
      
      date = parse_date(row['date'])
      is_weekend = [0, 6].include?(date.wday)
      is_holiday = @holiday_service.holiday?(date)

      # Check if both time_in and time_out are not 00:00:00
      is_present = !is_weekend && !is_holiday && parse_time(row['time_in'].to_i).present? && parse_time(row['time_out'].to_i).present?

      attendance_data = {
        user_id: user.id,
        date: parse_date(row['date']),
        time_in: is_weekend || is_holiday ? nil : parse_time(row['time_in'].to_i),
        time_out: is_weekend || is_holiday ? nil : parse_time(row['time_out'].to_i),
        present: is_present,
        # holiday_name: is_holiday ? @holiday_service.holiday_name(date) : nil
      }

      Attendance.create(attendance_data)
    else
      raise "Employee with code #{row['employee_code']} not found."
    end
  end

  # def parse_date(date_string)
  #   # Assuming date_string is in a format that can be parsed by Chronic
  #   Chronic.parse(date_string)
  # end

  def parse_date(date_string)
  # Assuming date_string is in "DD/MM/YY" format
  Date.strptime(date_string, '%d/%m/%y')
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
end
