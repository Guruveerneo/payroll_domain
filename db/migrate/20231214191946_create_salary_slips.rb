class CreateSalarySlips < ActiveRecord::Migration[7.0]
  def change
    create_table :salary_slips do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :year
      t.integer :month

      t.timestamps
    end
  end
end
