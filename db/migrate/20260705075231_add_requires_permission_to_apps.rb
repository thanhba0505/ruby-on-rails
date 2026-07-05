class AddRequiresPermissionToApps < ActiveRecord::Migration[8.1]
  def change
    add_column :apps, :requires_permission, :boolean, default: false, null: false
  end
end
