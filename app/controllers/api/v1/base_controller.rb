module Api
  module V1
    class BaseController < ApplicationController
      include ApiResponse
      include ApiAuthentication
      include ApiAuthorization

      rescue_from ActiveRecord::RecordNotFound do
        render_error(message: I18n.t("errors.not_found"), errors: [ "Not Found" ], status: :not_found)
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render_error(message: I18n.t("common.validation_failed"), errors: e.record.errors.full_messages, status: :unprocessable_entity)
      end

      rescue_from ActionController::ParameterMissing do |e|
        render_error(
          message: I18n.t("errors.parameter_missing"),
          errors: [ I18n.t("errors.parameter_missing_detail", param: e.param) ],
          status: :bad_request
        )
      end

      rescue_from JwtService::ExpiredTokenError do
        render_error(message: I18n.t("auth.token_expired"), errors: [ "Unauthorized" ], status: :unauthorized)
      end

      rescue_from JwtService::InvalidTokenError do
        render_error(message: I18n.t("auth.invalid_token"), errors: [ "Unauthorized" ], status: :unauthorized)
      end
    end
  end
end
