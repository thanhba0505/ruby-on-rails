class UserDesktopApp < ApplicationRecord
  belongs_to :user
  belongs_to :app

  validates :user_id, uniqueness: { scope: :app_id }
  validates :grid_x, presence: true
  validates :grid_y, presence: true
  validates :user_id, uniqueness: { scope: %i[grid_x grid_y] }
end
