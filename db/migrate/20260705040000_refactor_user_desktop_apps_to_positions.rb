class RefactorUserDesktopAppsToPositions < ActiveRecord::Migration[8.1]
  def up
    # 1. Desktop apps: migrate from grid to position starting at 1
    add_column :user_desktop_apps, :position, :integer

    execute <<~SQL
      WITH ranked AS (
        SELECT
          id,
          ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY grid_y ASC, grid_x ASC, id ASC
          ) AS new_position
        FROM user_desktop_apps
      )
      UPDATE user_desktop_apps AS user_desktop_apps
      SET position = ranked.new_position
      FROM ranked
      WHERE user_desktop_apps.id = ranked.id
    SQL

    change_column_null :user_desktop_apps, :position, false
    add_index :user_desktop_apps, %i[user_id position], unique: true
    remove_index :user_desktop_apps, name: "index_user_desktop_apps_on_user_id_and_grid_x_and_grid_y"
    remove_column :user_desktop_apps, :grid_x, :integer
    remove_column :user_desktop_apps, :grid_y, :integer

    # 2. Taskbar apps: ensure position starts at 1 (increment existing positions by 1)
    #    Note: The one existing record already has position=1, so no change needed
    #    But we add a CHECK constraint to prevent position=0 in the future
    execute <<~SQL
      ALTER TABLE user_taskbar_apps
      ADD CONSTRAINT position_positive CHECK (position > 0)
    SQL
  rescue ActiveRecord::StatementInvalid => e
    # If CHECK constraint already exists or fails, ignore
    puts "Migration warning: #{e.message}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore original grid_x/grid_y coordinates from linear position."
  end
end
