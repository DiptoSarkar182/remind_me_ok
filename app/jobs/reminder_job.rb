class ReminderJob < ApplicationJob
  queue_as :default

  def perform(remind_me)
    ReminderMailer.reminder_email(remind_me).deliver_now
  end
end