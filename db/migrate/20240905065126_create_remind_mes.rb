class CreateRemindMes < ActiveRecord::Migration[7.2]
  def change
    create_table :remind_mes do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false, default: ""
      t.datetime :remind_me_date_time, null: false
      t.timestamps
    end
  end
end
