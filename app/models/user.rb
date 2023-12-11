class User < ApplicationRecord
  has_secure_password

  validates :name, :employee_code, :email, :password_digest, presence: true
  validates :email, uniqueness: true
  has_many :attendances

 # def check_in(date = Date.today)
 #    attendances.create(time_in: Time.now)
 # end

 # def check_out(date = Date.today)
 #    attendance = attendances.find_by(time_in: date)
 #    attendance.update(time_out: Time.now) if attendance
 # end

 # def is_checked_in?(date = Date.today)
 #    attendances.any? { |attendance| attendance.time_in.to_date == date && attendance.time_out.nil? }
 # end 
end
