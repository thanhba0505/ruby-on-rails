# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |origin, _env|
      next false if origin.blank?

      if Rails.env.production?
        allowed = ENV.fetch("CORS_ORIGINS", "").split(",").map(&:strip).reject(&:blank?)
        allowed.include?(origin)
      else
        origin.match?(/\Ahttps?:\/\/(localhost|127\.0\.0\.1)(:\d+)?\z/)
      end
    end

    resource "*",
      headers: :any,
      expose: %w[Authorization],
      methods: %i[get post put patch delete options head],
      max_age: 600
  end
end
