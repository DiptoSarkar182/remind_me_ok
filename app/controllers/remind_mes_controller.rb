class RemindMesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_remind_me, only: [:edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]
  before_action :load_current_user, only: [:new, :edit]

  def new
    @remind_me = RemindMe.new
  end

  def create
    @remind_me = current_user.remind_mes.build(remind_me_params)

    if current_user.time_zone.blank? || current_user.time_zone != params[:remind_me][:time_zone]
      current_user.update(time_zone: params[:remind_me][:time_zone])
    end

    if @remind_me.save
      ReminderJob.set(wait_until: @remind_me.remind_me_date_time).perform_later(@remind_me)
      redirect_to dashboards_path, notice: "Reminder created successfully"
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if current_user.time_zone.blank? || current_user.time_zone != params[:remind_me][:time_zone]
      current_user.update(time_zone: params[:remind_me][:time_zone])
    end

    if @remind_me.update(remind_me_params)
      redirect_to dashboards_path, notice: "Reminder updated successfully"
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @remind_me.destroy
    redirect_to dashboards_path, notice: "Reminder deleted successfully"
  end

  private

  def set_remind_me
    @remind_me = RemindMe.find(params[:id])
  end

  def authorize_user!
    redirect_to dashboards_path, alert: "You are not authorized to perform this action." unless @remind_me&.user == current_user
  end

  def remind_me_params
    params.require(:remind_me).permit(:remind_me_date_time, :subject, :content)
  end

  def load_current_user
    @current_user = current_user
  end

end
