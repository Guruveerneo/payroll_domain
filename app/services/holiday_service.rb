class HolidayService
  def initialize
    @holidays = [
      { name: "Republic Day", date: Date.new(2023, 1, 26) },
      { name: "Holi", date: Date.new(2023, 3, 7) },
      { name: "Gudi Padwa", date: Date.new(2023, 3, 22) },
      { name: "Eid-Ul-Fitr", date: Date.new(2023, 4, 22) },
      { name: "Maharashtra Day", date: Date.new(2023, 4, 1) },
      { name: "Independence Day", date: Date.new(2023, 8, 15) },
      { name: "Ganesh Chaturthi", date: Date.new(2023, 8, 19) },
      { name: "Ananth Chaturthi", date: Date.new(2023, 9, 28) },
      { name: "Gandhi Jayanti", date: Date.new(2023, 10, 2) },
      { name: "Dussera", date: Date.new(2023, 10, 24) },
      { name: "Lakshmi Puja", date: Date.new(2023, 11, 12) },
      { name: "Diwali New Year", date: Date.new(2023, 11, 14) },
      { name: "Christmas", date: Date.new(2023, 12, 25) } # Add a comma here
    ]
  end

  def holidays_in_month(year, month)
  @holidays.select { |holiday| holiday[:date].year == year && holiday[:date].month == month }
end


  def holiday?(date)
    # Check if the given date is a holiday
    # @holidays.any? { |holiday| holiday[:date] == date }
    @holidays.any? { |holiday| holiday[:date].to_date == date.to_date }

  end

  def holiday_name(date)
    # Get the name of the holiday for the given date
    holiday = @holidays.find { |h| h[:date] == date }
    holiday ? holiday[:name] : nil
  end
end
