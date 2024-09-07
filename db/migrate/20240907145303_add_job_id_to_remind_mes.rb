class AddJobIdToRemindMes < ActiveRecord::Migration[7.2]
  def change
    add_column :remind_mes, :job_id, :string, null: false, default: ""
  end
end
