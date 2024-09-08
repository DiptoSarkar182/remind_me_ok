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

    if current_user.time_zone.blank? || current_user.time_zone != params[:remind_me][:remind_me_time_zone]
      current_user.update(time_zone: params[:remind_me][:remind_me_time_zone])
    end

    # Convert the remind_me_date_time to UTC based on user's time zone
    reminder_time_in_utc = remind_me_params[:remind_me_date_time].in_time_zone(params[:remind_me][:remind_me_time_zone]).utc
    @remind_me.remind_me_date_time = reminder_time_in_utc

    if @remind_me.save
      # Schedule the job at the converted UTC time and store the job ID
      job = ReminderJob.set(wait_until: reminder_time_in_utc).perform_later(@remind_me)
      @remind_me.update(job_id: job.provider_job_id)
      redirect_to dashboards_path, notice: "Reminder created successfully"
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if current_user.time_zone.blank? || current_user.time_zone != params[:remind_me][:remind_me_time_zone]
      current_user.update(time_zone: params[:remind_me][:remind_me_time_zone])
    end

    # Convert the remind_me_date_time to UTC based on user's time zone
    reminder_time_in_utc = remind_me_params[:remind_me_date_time].in_time_zone(params[:remind_me][:remind_me_time_zone]).utc

    ActiveRecord::Base.transaction do
      # Lock the reminder record to prevent race conditions
      @remind_me.lock!

      if @remind_me.update(remind_me_params.merge(remind_me_date_time: reminder_time_in_utc))
        # Find the associated job using the stored job ID
        job = GoodJob::Job.find_by(active_job_id: @remind_me.job_id)

        # If the job is scheduled and not yet performed, update it
        if job && job.scheduled_at > Time.current && job.performed_at.nil?
          job.update(scheduled_at: reminder_time_in_utc)
        end

        redirect_to dashboards_path, notice: "Reminder updated successfully"
      else
        render 'edit', status: :unprocessable_entity
      end
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      # Lock the reminder record to prevent race conditions
      @remind_me.lock!

      # Find the associated job using the stored job ID
      job = GoodJob::Job.find_by(active_job_id: @remind_me.job_id)

      # If the job is scheduled and not yet performed, delete it
      if job && job.scheduled_at > Time.current && job.performed_at.nil?
        job.destroy
      end

      # Destroy the reminder
      @remind_me.destroy
    end

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
    params.require(:remind_me).permit(:remind_me_date_time, :subject, :content, :remind_me_time_zone)
  end

  def load_current_user
    @current_user = current_user
  end
end