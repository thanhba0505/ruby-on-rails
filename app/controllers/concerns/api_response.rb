module ApiResponse
  extend ActiveSupport::Concern

  def render_success(data: {}, message: nil, status: :ok)
    message ||= I18n.t("common.fetch_success")
    render json: { success: true, message: message, data: data, errors: nil }, status: status
  end

  def render_error(message: nil, errors: nil, status: :unprocessable_entity)
    message ||= I18n.t("common.validation_failed")
    errors_payload = errors.nil? ? nil : Array(errors)
    render json: { success: false, message: message, data: nil, errors: errors_payload }, status: status
  end
end
