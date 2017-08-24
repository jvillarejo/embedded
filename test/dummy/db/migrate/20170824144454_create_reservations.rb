class CreateReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :reservations do |t|
      t.timestamp :time_interval_start_time
      t.timestamp :time_interval_end_time

      t.timestamps
    end
  end
end
