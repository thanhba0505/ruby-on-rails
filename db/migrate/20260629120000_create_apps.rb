class CreateApps < ActiveRecord::Migration[8.0]
  def change
    create_table :apps do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :icon
      t.text :description
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end

    add_index :apps, :code, unique: true
    add_index :apps, :name, unique: true
  end
end
