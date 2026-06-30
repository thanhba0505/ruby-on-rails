# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_30_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "apps", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "code" ], name: "index_apps_on_code", unique: true
    t.index [ "name" ], name: "index_apps_on_name", unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index [ "key" ], name: "index_permissions_on_key", unique: true
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "jti", null: false
    t.string "replaced_by_jti"
    t.datetime "revoked_at"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index [ "expires_at" ], name: "index_refresh_tokens_on_expires_at"
    t.index [ "jti" ], name: "index_refresh_tokens_on_jti", unique: true
    t.index [ "revoked_at" ], name: "index_refresh_tokens_on_revoked_at"
    t.index [ "token_digest" ], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index [ "user_id" ], name: "index_refresh_tokens_on_user_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "permission_id", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "permission_id" ], name: "index_role_permissions_on_permission_id"
    t.index [ "role_id", "permission_id" ], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index [ "role_id" ], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_admin", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "code" ], name: "index_roles_on_code", unique: true
    t.index [ "is_admin" ], name: "index_roles_on_is_admin"
  end

  create_table "uploaded_files", force: :cascade do |t|
    t.bigint "bytes"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "folder"
    t.string "format"
    t.integer "height"
    t.jsonb "metadata", default: {}, null: false
    t.string "original_filename"
    t.string "provider", default: "cloudinary", null: false
    t.string "public_id", null: false
    t.string "resource_type", default: "image", null: false
    t.text "secure_url", null: false
    t.datetime "updated_at", null: false
    t.text "url"
    t.integer "width"
    t.index [ "deleted_at" ], name: "index_uploaded_files_on_deleted_at"
    t.index [ "provider", "public_id" ], name: "index_uploaded_files_on_provider_and_public_id", unique: true
  end

  create_table "user_desktop_apps", force: :cascade do |t|
    t.bigint "app_id", null: false
    t.datetime "created_at", null: false
    t.integer "grid_x", null: false
    t.integer "grid_y", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index [ "app_id" ], name: "index_user_desktop_apps_on_app_id"
    t.index [ "user_id", "app_id" ], name: "index_user_desktop_apps_on_user_id_and_app_id", unique: true
    t.index [ "user_id", "grid_x", "grid_y" ], name: "index_user_desktop_apps_on_user_id_and_grid_x_and_grid_y", unique: true
    t.index [ "user_id" ], name: "index_user_desktop_apps_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index [ "role_id" ], name: "index_user_roles_on_role_id"
    t.index [ "user_id", "role_id" ], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index [ "user_id" ], name: "index_user_roles_on_user_id"
  end

  create_table "user_taskbar_apps", force: :cascade do |t|
    t.bigint "app_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index [ "app_id" ], name: "index_user_taskbar_apps_on_app_id"
    t.index [ "user_id", "app_id" ], name: "index_user_taskbar_apps_on_user_id_and_app_id", unique: true
    t.index [ "user_id", "position" ], name: "index_user_taskbar_apps_on_user_id_and_position", unique: true
    t.index [ "user_id" ], name: "index_user_taskbar_apps_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "avatar_id"
    t.bigint "background_id"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index [ "avatar_id" ], name: "index_users_on_avatar_id"
    t.index [ "background_id" ], name: "index_users_on_background_id"
    t.index [ "email" ], name: "index_users_on_email", unique: true
  end

  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "user_desktop_apps", "apps"
  add_foreign_key "user_desktop_apps", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "user_taskbar_apps", "apps"
  add_foreign_key "user_taskbar_apps", "users"
  add_foreign_key "users", "uploaded_files", column: "avatar_id"
  add_foreign_key "users", "uploaded_files", column: "background_id"
end
