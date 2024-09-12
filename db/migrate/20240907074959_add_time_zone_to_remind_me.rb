class AddTimeZoneToRemindMe < ActiveRecord::Migration[7.2]
  def change
    add_column :remind_mes, :time_zone, :string
  end
end
