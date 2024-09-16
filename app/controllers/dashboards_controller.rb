class DashboardsController < ApplicationController

  before_action :authenticate_user!
  def index
    current_time = Time.current
    @reminded_you = current_user.remind_mes.where('remind_me_date_time <= ?', current_time).page(params[:reminded_you_page]).per(1)
    @will_remind_you = current_user.remind_mes.where('remind_me_date_time > ?', current_time).page(params[:will_remind_you_page]).per(8)
  end
end
