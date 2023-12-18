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

  def open_spreadsheet
    Roo::Spreadsheet.open(@file.path)
  rescue Roo::Spreadsheet::UnknownFileType
    raise 'Invalid file format. Please upload a valid Excel file.'
  end
  
  def process_attendance_row(row)
    user = User.find_by(employee_code: row['employee_code'])

    if user.present?
      date = parse_date(row['date'])

      # Check if there is any attendance entry for the given user and date
      existing_attendance = Attendance.where(user_id: user.id, date: date.beginning_of_day..date.end_of_day).first || Attendance.find_by(user_id: user.id, date: date)

      if !existing_attendance.blank?
        puts "Attendance entry already exists for #{row['date']} - #{user.employee_code}. Skipping."
      else
        create_attendance(user, row)
      end
    else
      raise "Employee with code #{row['employee_code']} not found."
    end
  end

  private

  def create_attendance(user, row)
    date = parse_date(row['date'])
    is_weekend = [0, 6].include?(date.wday)
    is_holiday = @holiday_service.holiday?(date)
    is_fixed_holiday = @holiday_service.holidays_in_month(date.year, date.month).any? { |holiday| parse_date(holiday[:date]) == date }

    # Skip entries for Saturday, Sunday, and fixed holidays
    return if is_weekend || is_holiday || is_fixed_holiday

    is_present = !(parse_time(row['time_in'].to_i) == '00:00:00' && parse_time(row['time_out'].to_i) == '00:00:00')

    attendance_data = {
      user_id: user.id,
      date: date,
      time_in: parse_time(row['time_in'].to_i),
      time_out: parse_time(row['time_out'].to_i),
      present: is_present,
    }

    Attendance.create(attendance_data)
  end

  def parse_date(date_string)
    Chronic.parse(date_string)
  end

  def parse_time(seconds)
    return nil if seconds.blank?

    hours, remainder = seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    formatted_time = "#{format('%02d', hours)}:#{format('%02d', minutes)}:#{format('%02d', seconds)}"
    Time.parse(formatted_time).strftime('%H:%M:%S')
  end
end