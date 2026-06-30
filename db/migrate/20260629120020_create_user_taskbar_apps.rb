class CreateUserTaskbarApps < ActiveRecord::Migration[8.0]
  def change
    create_table :user_taskbar_apps do |t|
      t.references :user, null: false, foreign_key: true
      t.references :app, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :user_taskbar_apps, %i[user_id app_id], unique: true
    add_index :user_taskbar_apps, %i[user_id position], unique: true
  end
end
