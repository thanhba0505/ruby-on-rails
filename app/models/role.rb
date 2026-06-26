class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, -> { distinct }, through: :role_permissions

  before_validation :normalize_code

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }

  private

  def normalize_code
    self.code = code.to_s.strip.downcase.presence
  end
end
