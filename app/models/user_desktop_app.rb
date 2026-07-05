class UserDesktopApp < ApplicationRecord
  belongs_to :user
  belongs_to :app

  validates :user_id, uniqueness: { scope: :app_id }
  validates :position, presence: true
  validates :user_id, uniqueness: { scope: :position }
end
