class AddLeaveBalanceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :leave_balance, :float
  end
end
