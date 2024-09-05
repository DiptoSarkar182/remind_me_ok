class ReminderMailer < ApplicationMailer

  def reminder_email(remind_me)
    @remind_me = remind_me
    mail(to: @remind_me.user.email, subject: @remind_me.subject)
  end

end
