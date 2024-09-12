class RenameTimeZoneInRemindMes < ActiveRecord::Migration[7.2]
  def change
    rename_column :remind_mes, :time_zone, :remind_me_time_zone
  end
end
