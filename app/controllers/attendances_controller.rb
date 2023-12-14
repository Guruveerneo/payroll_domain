class AttendancesController < ApplicationController
  require 'chronic'
  include AttendancesHelper

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
      AttendanceFileService.new(file).process_file
      flash[:notice] = 'Attendance data imported successfully!'
      redirect_to attendances_path
    rescue StandardError => e
      flash[:alert] = e.message
      redirect_to new_attendance_path
    end
  end

  def list_view
    @attendances = filter_attendances(params[:employee_code], params[:month], params[:year])
  end

  def calendar_view
    @users = User.all
    @employee_code = params[:employee_code] || @users.first&.employee_code
    @selected_month = params[:selected_month] || Date.current.month

    user = User.find_by(employee_code: @employee_code)


	    if user
	    # Initialize events array
	    @events = []

	    # Determine the last day of the selected month
	    last_day = Date.new(Date.current.year, @selected_month.to_i, -1).day

	    # Iterate over days of the selected month and create events for each user_id
	    (1..last_day).each do |day|
	      date = Date.new(Date.current.year, @selected_month.to_i, day)
	      @events << {
	        title: "User ID: #{user.id}",
	        start: date,
	        className: 'event-user-id'
	      }
	    end

	    # Rails.logger.info("Employee Code: #{@employee_code}, Selected Month: #{@selected_month}")
	    # Rails.logger.info("Events: #{@events.inspect}")

	     # render json: { events: @events }
	  else
	    Rails.logger.error("User not found for the given employee_code: #{@employee_code}")
	    render json: { error: 'User not found for the given employee_code' }, status: :unprocessable_entity
	  end
  end

  private

 def filter_attendances(employee_code, month, year)
  attendances = Attendance.all

  attendances = attendances.where(user_id: User.where(employee_code: employee_code).pluck(:id)) if employee_code.present?

 if params['date'].present? && params['date']['month'].present? && params['date']['year'].present?
    start_date = Date.new(params['date']['year'].to_i, params['date']['month'].to_i, 1)
    end_date = start_date.end_of_month
    attendances = attendances.where(date: start_date..end_date)
  end

  attendances
end




  def attendance_params
    params.require(:attendance).permit(:file)
  end
end
