class HealthController < ApplicationController
  def show
    db_connected = database_connected?

    render json: {
      status: db_connected ? "ok" : "error",
      database: db_connected ? "connected" : "disconnected"
    }, status: db_connected ? :ok : :service_unavailable
  end

  private

  def database_connected?
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.select_value("SELECT 1")
    end

    true
  rescue StandardError
    false
  end
end
