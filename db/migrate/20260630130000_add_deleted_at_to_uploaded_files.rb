class AddDeletedAtToUploadedFiles < ActiveRecord::Migration[8.1]
  def change
    add_column :uploaded_files, :deleted_at, :datetime
    add_index :uploaded_files, :deleted_at
  end
end
