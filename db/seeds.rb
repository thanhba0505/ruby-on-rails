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

  admin_role = Role.find_or_initialize_by(code: "admin")
  admin_role.name = "Admin"
  admin_role.is_admin = true
  admin_role.save!

  admin_user = User.find_or_initialize_by(email: "admin@example.com")
  admin_user.name = "Admin"
  admin_user.is_admin = true
  admin_user.password = "123" if admin_user.password_digest.blank?
  admin_user.save!

  UserRole.find_or_create_by!(user: admin_user, role: admin_role)

  Permission.find_each do |permission|
    RolePermission.find_or_create_by!(role: admin_role, permission: permission)
  end
end
