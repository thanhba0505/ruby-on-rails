class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  before_validation :normalize_key

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :value, presence: true

  private

  def normalize_key
    self.key = key.to_s.strip.downcase.presence
  end
end
