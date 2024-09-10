class RemindMe < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true
  validates :content, presence: true
  validates :remind_me_date_time, presence: true
  validates :remind_me_time_zone, presence: true
  validate :remind_me_date_time_cannot_be_in_the_past

  encrypts :subject, :content

  private

  def remind_me_date_time_cannot_be_in_the_past
    if remind_me_date_time.present? && remind_me_date_time < Time.current
      errors.add(:remind_me_date_time, "can't be in the past")
    end
  end
end