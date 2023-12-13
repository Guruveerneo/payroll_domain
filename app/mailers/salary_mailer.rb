class SalaryMailer < ApplicationMailer
  def send_salary_slip(user, salary_details)
    @user = user
    @salary_details = salary_details

     mail(to: @user.email, subject: 'Your Salary Slip') do |format|
      format.html { render html: render_to_string('users/view_salary_slip_details', layout: false) }
   end
end
end