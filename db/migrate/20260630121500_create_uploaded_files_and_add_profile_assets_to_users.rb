class CreateUploadedFilesAndAddProfileAssetsToUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :uploaded_files do |t|
      t.string :provider, null: false, default: "cloudinary"
      t.string :public_id, null: false
      t.string :resource_type, null: false, default: "image"
      t.string :format
      t.bigint :bytes
      t.integer :width
      t.integer :height
      t.string :original_filename
      t.string :content_type
      t.string :folder
      t.text :url
      t.text :secure_url, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :uploaded_files, [ :provider, :public_id ], unique: true

    add_reference :users, :avatar, foreign_key: { to_table: :uploaded_files }
    add_reference :users, :background, foreign_key: { to_table: :uploaded_files }
  end
end
