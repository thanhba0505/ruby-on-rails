seed_root = Rails.root.join("db", "seeds")
available_seed_files = Dir[seed_root.join("*.rb")].map { |path| File.basename(path, ".rb") }.sort
development_seed_files = %w[permissions apps admin_bootstrap]
production_seed_files = %w[permissions apps admin_bootstrap]

selected_seed_files =
  if Rails.env.production?
    production_seed_files
  else
    development_seed_files
  end

unknown_seed_files = selected_seed_files - available_seed_files
if unknown_seed_files.any?
  raise "Unknown seed files: #{unknown_seed_files.join(', ')}. Available: #{available_seed_files.join(', ')}"
end

selected_seed_files.each do |seed_file|
  puts "== Seeding #{seed_file}"
  load seed_root.join("#{seed_file}.rb").to_s
end
