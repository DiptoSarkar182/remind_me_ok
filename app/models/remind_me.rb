class RemindMe < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true
  validates :content, presence: true
  validates :remind_me_date_time, presence: true
  validates :remind_me_time_zone, presence: true
  validate :remind_me_date_time_cannot_be_in_the_past

  encrypts :subject, :content

  before_destroy :destroy_associated_job

  private

  def remind_me_date_time_cannot_be_in_the_past
    if remind_me_date_time.present? && remind_me_date_time < Time.current
      errors.add(:remind_me_date_time, "can't be in the past")
    end
  end

  def destroy_associated_job
    job = GoodJob::Job.find_by(active_job_id: job_id)
    job.destroy if job && job.scheduled_at > Time.current && job.performed_at.nil?
  end

end