class User < ApplicationRecord
  has_secure_password

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, on: :create

  def bootstrap_admin?
    email == ENV.fetch("ADMIN_EMAIL", "admin@gmail.com").to_s.strip.downcase
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
