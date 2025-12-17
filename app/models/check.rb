class Check < ApplicationRecord
  belongs_to :site

  validates :status_code, presence: true
  validates :response_time_ms, presence: true

  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :last_hour, -> { where("created_at > ?", 1.hour.ago) }
  scope :last_24_hours, -> { where("created_at > ?", 24.hours.ago) }
  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
end
