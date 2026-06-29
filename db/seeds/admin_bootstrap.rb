admin_email = ENV.fetch("ADMIN_EMAIL", "admin@gmail.com").to_s.strip.downcase
admin_name = ENV.fetch("ADMIN_NAME", "Admin").to_s.strip
admin_password =
  ENV["ADMIN_PASSWORD"].presence ||
  if Rails.env.production?
    raise "ADMIN_PASSWORD is required in production"
  else
    "123123"
  end

ActiveRecord::Base.transaction do
  admin_role = Role.find_or_initialize_by(code: "admin")
  admin_role.name = "Admin"
  admin_role.is_admin = true
  admin_role.save!

  admin_user =
    User.joins(:roles).where(is_admin: true, roles: { id: admin_role.id }).order(:id).first ||
    User.find_by(email: admin_email) ||
    User.new

  admin_user.email = admin_email
  admin_user.name = admin_name
  admin_user.is_admin = true
  admin_user.password = admin_password
  admin_user.save!

  UserRole.find_or_create_by!(user: admin_user, role: admin_role)

  Permission.find_each do |permission|
    RolePermission.find_or_create_by!(role: admin_role, permission: permission)
  end
end
