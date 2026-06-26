class User < ApplicationRecord
  has_secure_password

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :permissions, -> { distinct }, through: :roles

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, on: :create

  def has_permission?(permission_key)
    permissions.exists?(key: permission_key)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
