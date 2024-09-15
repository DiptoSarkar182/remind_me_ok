class RemindMesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_remind_me, only: [:edit, :update, :show, :destroy, :delete_from_show_page]
  before_action :authorize_user!, only: [:edit, :update, :destroy]
  before_action :load_current_user, only: [:new, :edit]

  def new
    @remind_me = RemindMe.new
  end

  def create
    @remind_me = current_user.remind_mes.build(remind_me_params)

    # Convert the remind_me_date_time to UTC based on the provided time zone
    if remind_me_params[:remind_me_date_time].present? && remind_me_params[:remind_me_time_zone].present?
      reminder_time_in_utc = remind_me_params[:remind_me_date_time].in_time_zone(remind_me_params[:remind_me_time_zone]).utc
      @remind_me.remind_me_date_time = reminder_time_in_utc
    end

    # Update user's time zone if necessary
    if current_user.time_zone.blank? || current_user.time_zone != remind_me_params[:remind_me_time_zone]
      current_user.update(time_zone: remind_me_params[:remind_me_time_zone])
    end

    ActiveRecord::Base.transaction do
      if @remind_me.save
        # Schedule the job at the converted UTC time and store the job ID
        job = ReminderJob.set(wait_until: reminder_time_in_utc).perform_later(@remind_me)
        @remind_me.update!(job_id: job.provider_job_id)
        redirect_to dashboards_path, notice: "Reminder created successfully"
      else
        render 'new', status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    # Lock the reminder record to prevent race conditions
    @remind_me.lock!

    # Convert the remind_me_date_time to UTC based on user's time zone
    if remind_me_params[:remind_me_date_time].present? && remind_me_params[:remind_me_time_zone].present?
      reminder_time_in_utc = remind_me_params[:remind_me_date_time].in_time_zone(remind_me_params[:remind_me_time_zone]).utc
      @remind_me.remind_me_date_time = reminder_time_in_utc
    end

    ActiveRecord::Base.transaction do
      if @remind_me.update(remind_me_params.merge(remind_me_date_time: reminder_time_in_utc))
        # Update user's time zone if necessary
        if current_user.time_zone.blank? || current_user.time_zone != remind_me_params[:remind_me_time_zone]
          current_user.update(time_zone: remind_me_params[:remind_me_time_zone])
        end

        # Find the associated job using the stored job ID
        job = GoodJob::Job.find_by(active_job_id: @remind_me.job_id)

        if job && job.performed_at.nil?
          # If the job is scheduled and not yet performed, update it
          job.update(scheduled_at: reminder_time_in_utc)
        else
          # If the job has already been performed, create a new job
          new_job = ReminderJob.set(wait_until: reminder_time_in_utc).perform_later(@remind_me)
          @remind_me.update(job_id: new_job.provider_job_id)
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

    current_time = Time.current
    @reminded_you = current_user.remind_mes.where('remind_me_date_time <= ?', current_time)
    @will_remind_you = current_user.remind_mes.where('remind_me_date_time > ?', current_time)

    respond_to do |format|
      format.html { render partial: "dashboards/reminders_dashboard", locals: { reminded_you: @reminded_you, will_remind_you: @will_remind_you } }
    end
  end

  def delete_from_show_page
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

    respond_to do |format|
      format.html { redirect_to dashboards_path, notice: "Reminder deleted successfully" }
    end
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