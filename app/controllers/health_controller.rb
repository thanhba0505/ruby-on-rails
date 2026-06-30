class HealthController < ApplicationController
  def show
    checks = {
      database: database_connected? ? "connected" : "disconnected"
    }

    if include_cloudinary_check?
      checks[:cloudinary] = cloudinary_status
    end

    overall_ok = checks.values.all? { |status| %w[connected skipped].include?(status) }

    render json: checks.merge(status: overall_ok ? "ok" : "error"),
      status: overall_ok ? :ok : :service_unavailable
  end

  private

  def include_cloudinary_check?
    ActiveModel::Type::Boolean.new.cast(params[:include_cloudinary] || params[:cloudinary] || params[:full])
  end

  def database_connected?
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.select_value("SELECT 1")
    end

    true
  rescue StandardError
    false
  end

  def cloudinary_status
    return "skipped" unless Uploads::CloudinaryUploader.configured?

    Timeout.timeout(3) do
      response = Cloudinary::Api.ping
      return response["status"] == "ok" ? "connected" : "disconnected"
    end
  rescue StandardError, Timeout::Error
    "disconnected"
  end
end
