class DashboardsController < ApplicationController

  before_action :authenticate_user!
  def index
    current_time = Time.current
    @reminded_you = current_user.remind_mes.where('remind_me_date_time <= ?', current_time)
    @will_remind_you = current_user.remind_mes.where('remind_me_date_time > ?', current_time)
  end
end
