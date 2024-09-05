class AddSubjectToRemindMe < ActiveRecord::Migration[7.2]
  def change
    add_column :remind_mes, :subject, :string, null: false, default: ""
  end
end
