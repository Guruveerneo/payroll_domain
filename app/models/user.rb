class User < ApplicationRecord
  has_secure_password

  validates :name, :employee_code, :email, :password_digest, presence: true
  validates :email, :employee_code, uniqueness: true
  has_many :attendances 
  has_many :salary_slips
end
