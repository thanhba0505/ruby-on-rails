class App < ApplicationRecord
  has_many :user_desktop_apps, dependent: :destroy
  has_many :user_taskbar_apps, dependent: :destroy

  before_validation :normalize_code

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :requires_permission, inclusion: { in: [true, false] }

  scope :requires_permission, -> { where(requires_permission: true) }
  scope :no_permission_required, -> { where(requires_permission: false) }

  private

  def normalize_code
    self.code = code.to_s.strip.downcase.presence
  end
end
