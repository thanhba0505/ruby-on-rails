class CreateUserDesktopApps < ActiveRecord::Migration[8.0]
  def change
    create_table :user_desktop_apps do |t|
      t.references :user, null: false, foreign_key: true
      t.references :app, null: false, foreign_key: true
      t.integer :grid_x, null: false
      t.integer :grid_y, null: false

      t.timestamps
    end

    add_index :user_desktop_apps, %i[user_id app_id], unique: true
    add_index :user_desktop_apps, %i[user_id grid_x grid_y], unique: true
  end
end
