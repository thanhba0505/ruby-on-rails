class User < ApplicationRecord
  has_secure_password

  ICON_SIZES = %w[small medium large].freeze

  store_accessor :settings, :icon_size

  belongs_to :avatar, class_name: "UploadedFile", optional: true
  belongs_to :background, class_name: "UploadedFile", optional: true

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :permissions, -> { distinct }, through: :roles
  has_many :user_desktop_apps, dependent: :destroy
  has_many :desktop_apps, through: :user_desktop_apps, source: :app
  has_many :user_taskbar_apps, dependent: :destroy
  has_many :taskbar_apps, through: :user_taskbar_apps, source: :app

  before_validation :normalize_email
  before_validation :normalize_settings

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, on: :create
  validate :validate_icon_size

  def has_permission?(permission_key)
    permissions.exists?(key: permission_key)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end

  def normalize_settings
    normalized_settings = settings.is_a?(Hash) ? settings.deep_stringify_keys : {}
    normalized_settings["icon_size"] = normalized_settings["icon_size"].presence
    self.settings = normalized_settings.slice("icon_size").compact
  end

  def validate_icon_size
    return if icon_size.blank? || ICON_SIZES.include?(icon_size)

    errors.add(:icon_size, :invalid_icon_size)
  end
end
