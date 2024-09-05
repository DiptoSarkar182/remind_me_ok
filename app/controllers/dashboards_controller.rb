class DashboardsController < ApplicationController

  before_action :authenticate_user!
  def index
    @remind_mes = current_user.remind_mes
  end
end
