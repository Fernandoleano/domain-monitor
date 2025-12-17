class Site < ApplicationRecord
  belongs_to :user
  has_many :checks, dependent: :destroy

  broadcasts_to ->(site) { [ site.user, "sites" ] }, inserts_by: :prepend

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :name, presence: true
  validates :check_interval, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  def last_check
    checks.order(created_at: :desc).first
  end

  def up?
    status == "up"
  end

  def uptime_percentage(period = 24.hours.ago)
    # Optimized SQL query: Count total vs success in one go
    stats = checks.where("created_at > ?", period).select("COUNT(*) as total, COUNT(CASE WHEN success THEN 1 END) as success_count").to_a.first

    total = stats&.total || 0
    return 100.0 if total.zero?

    success_count = stats&.success_count || 0
    (success_count.to_f / total.to_f * 100).round(2)
  end

  def avg_response_time(period = 24.hours.ago)
    # Optimized SQL: Database calculates average
    checks.where("created_at > ?", period).average(:response_time_ms).to_i
  end
end
