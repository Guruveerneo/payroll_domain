class SalarySlip < ApplicationRecord
  belongs_to :user

  validates :year, :month, presence: true
end