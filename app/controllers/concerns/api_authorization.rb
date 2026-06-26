module ApiAuthorization
  extend ActiveSupport::Concern

  def authorize_permission!(permission_key)
    return render_error(message: I18n.t("auth.unauthorized"), errors: [ "Unauthorized" ], status: :unauthorized) if current_user.nil?
    return true if current_user.has_permission?(permission_key)

    render_error(message: I18n.t("permission.denied"), errors: [ "Forbidden" ], status: :forbidden)
    false
  end
end
