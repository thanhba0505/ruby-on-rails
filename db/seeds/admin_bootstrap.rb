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
  admin_user =
    User.find_by(email: admin_email) ||
    User.new

  admin_user.email = admin_email
  admin_user.name = admin_name
  admin_user.password = admin_password
  admin_user.save!
end
