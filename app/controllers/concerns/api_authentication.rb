module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  def authenticate_user!
    token = bearer_token
    return render_error(message: I18n.t("auth.missing_token"), errors: [ "Unauthorized" ], status: :unauthorized) if token.blank?

    payload = JwtService.decode_access(token)
    user = User.find_by(id: payload["sub"])
    return render_error(message: I18n.t("auth.invalid_token"), errors: [ "Unauthorized" ], status: :unauthorized) if user.nil?

    @current_user = user
  rescue JwtService::ExpiredTokenError
    render_error(message: I18n.t("auth.token_expired"), errors: [ "Unauthorized" ], status: :unauthorized)
  rescue JwtService::InvalidTokenError
    render_error(message: I18n.t("auth.invalid_token"), errors: [ "Unauthorized" ], status: :unauthorized)
  end

  private

  def bearer_token
    auth_header = request.headers["Authorization"].to_s
    scheme, token = auth_header.split(" ", 2)
    return if scheme != "Bearer"

    token
  end
end
