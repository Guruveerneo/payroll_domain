class AddDetailsToSalarySlips < ActiveRecord::Migration[7.0]
  def change
    add_column :salary_slips, :details, :json
  end
end
