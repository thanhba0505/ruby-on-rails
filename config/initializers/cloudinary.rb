Cloudinary.config do |config|
  config.cloud_name = ENV["CLOUDINARY_CLOUD_NAME"].presence
  config.api_key = ENV["CLOUDINARY_API_KEY"].presence
  config.api_secret = ENV["CLOUDINARY_API_SECRET"].presence
  config.secure = ENV.fetch("CLOUDINARY_SECURE", "true") == "true"
end
