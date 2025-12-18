class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :sites, dependent: :destroy
  has_many :notifications, dependent: :destroy
  # has_one_attached :avatar # Removed in favor of database storage
  attribute :avatar_data, :binary
  attribute :avatar_content_type, :string

  def avatar=(attachable)
    return unless attachable.present?

    if attachable.is_a?(ActionDispatch::Http::UploadedFile)
      self.avatar_data = attachable.read
      self.avatar_content_type = attachable.content_type
    end
  end

  def avatar_attached?
    avatar_data.present?
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :full_name, presence: true

  def first_name
    full_name.split(" ").first
  end
end
