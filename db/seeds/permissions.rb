permission_seeds = [
  { key: "users.read", value: "Xem người dùng" },
  { key: "users.create", value: "Tạo người dùng" },
  { key: "users.update", value: "Cập nhật người dùng" },
  { key: "users.delete", value: "Xóa người dùng" },
  { key: "users.assign_roles", value: "Gán vai trò cho người dùng" },
  { key: "roles.read", value: "Xem vai trò" },
  { key: "roles.create", value: "Tạo vai trò" },
  { key: "roles.update", value: "Cập nhật vai trò" },
  { key: "roles.delete", value: "Xóa vai trò" },
  { key: "roles.assign_permissions", value: "Gán quyền cho vai trò" },
  { key: "permissions.read", value: "Xem quyền" },
  { key: "permissions.create", value: "Tạo quyền" },
  { key: "permissions.update", value: "Cập nhật quyền" },
  { key: "permissions.delete", value: "Xóa quyền" }
]

ActiveRecord::Base.transaction do
  permission_seeds.each do |attrs|
    permission = Permission.find_or_initialize_by(key: attrs[:key])
    permission.value = attrs[:value]
    permission.description = attrs[:description]
    permission.save!
  end
end
