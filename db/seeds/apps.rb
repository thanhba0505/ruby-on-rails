app_seeds = [
  { code: "app", name: "App", icon: "app", description: "App management", is_active: true },
  { code: "user", name: "User", icon: "user", description: "User management", is_active: true },
  { code: "role", name: "Role", icon: "shield", description: "Role management", is_active: true }
]

ActiveRecord::Base.transaction do
  app_seeds.each do |attrs|
    app = App.find_or_initialize_by(code: attrs[:code])
    app.name = attrs[:name]
    app.icon = attrs[:icon]
    app.description = attrs[:description]
    app.is_active = attrs[:is_active]
    app.save!
  end
end
