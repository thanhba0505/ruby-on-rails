class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.boolean :is_admin, null: false, default: false

      t.timestamps
    end

    add_index :roles, :code, unique: true
    add_index :roles, :is_admin
  end
end
