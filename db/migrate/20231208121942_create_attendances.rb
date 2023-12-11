class CreateAttendances < ActiveRecord::Migration[7.0]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :date
      t.boolean :present
      t.datetime :time_in
      t.datetime :time_out

      t.timestamps
    end
  end
end
