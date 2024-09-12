class ReminderMailer < ApplicationMailer

  def reminder_email(remind_me)
    @remind_me = remind_me
    @user_time_zone = @remind_me.remind_me_time_zone
    @remind_me_date_time_in_user_time_zone = @remind_me.remind_me_date_time.in_time_zone(@user_time_zone)
    mail(to: @remind_me.user.email, subject: @remind_me.subject)
  end

end
