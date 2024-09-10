class RemindMe < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true
  validates :content, presence: true
  validates :remind_me_date_time, presence: true
  validates :remind_me_time_zone, presence: true

  encrypts :subject, :content
end
