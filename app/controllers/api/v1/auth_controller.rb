module Api
  module V1
    class AuthController < BaseController
      def login
        email = params.require(:email).to_s.strip.downcase
        password = params.require(:password).to_s

        user = User.find_by(email: email)
        unless user&.authenticate(password)
          return render_error(message: I18n.t("auth.login_failed"), errors: [ "Unauthorized" ], status: :unauthorized)
        end

        issued = JwtService.issue_access_token_for_user(user)
        refresh_issued = JwtService.issue_refresh_token_for_user(user)
        RefreshToken.create!(
          user: user,
          jti: refresh_issued[:jti],
          token_digest: refresh_issued[:token_digest],
          expires_at: Time.at(refresh_issued[:exp])
        )

        render_success(
          data: {
            token: issued[:token],
            token_type: "Bearer",
            expires_in: JwtService.access_expiration_seconds,
            exp: issued[:exp],
            refresh_token: refresh_issued[:token],
            refresh_expires_in: JwtService.refresh_expiration_seconds,
            refresh_exp: refresh_issued[:exp],
            user: user_payload(user)
          },
          message: I18n.t("auth.login_success")
        )
      end

      def refresh
        token = params.require(:refresh_token).to_s

        payload = JwtService.decode_refresh(token)
        stored = RefreshToken.find_by(jti: payload["jti"])
        if stored.nil? || stored.revoked? || stored.expired? || stored.token_digest != JwtService.token_digest(token)
          return render_error(message: I18n.t("auth.refresh_failed"), errors: [ "Unauthorized" ], status: :unauthorized)
        end

        user = User.find_by(id: payload["sub"])
        if user.nil?
          stored.revoke!
          return render_error(message: I18n.t("auth.refresh_failed"), errors: [ "Unauthorized" ], status: :unauthorized)
        end

        new_refresh = JwtService.issue_refresh_token_for_user(user)
        RefreshToken.transaction do
          stored.revoke!(replaced_by_jti: new_refresh[:jti])
          RefreshToken.create!(
            user: user,
            jti: new_refresh[:jti],
            token_digest: new_refresh[:token_digest],
            expires_at: Time.at(new_refresh[:exp])
          )
        end

        access = JwtService.issue_access_token_for_user(user)
        render_success(
          data: {
            token: access[:token],
            token_type: "Bearer",
            expires_in: JwtService.access_expiration_seconds,
            exp: access[:exp],
            refresh_token: new_refresh[:token],
            refresh_expires_in: JwtService.refresh_expiration_seconds,
            refresh_exp: new_refresh[:exp]
          },
          message: I18n.t("auth.refresh_success")
        )
      rescue ActiveRecord::RecordNotFound
        render_error(message: I18n.t("auth.refresh_failed"), errors: [ "Unauthorized" ], status: :unauthorized)
      end

      def logout
        token = params.require(:refresh_token).to_s

        payload = JwtService.decode_refresh(token)
        stored = RefreshToken.find_by(jti: payload["jti"])
        if stored.nil? || stored.token_digest != JwtService.token_digest(token)
          return render_error(message: I18n.t("auth.logout_success"), errors: nil, status: :ok)
        end

        stored.revoke!
        render_success(data: {}, message: I18n.t("auth.logout_success"))
      rescue ActionController::ParameterMissing
        render_success(data: {}, message: I18n.t("auth.logout_success"))
      rescue JwtService::ExpiredTokenError, JwtService::InvalidTokenError
        render_success(data: {}, message: I18n.t("auth.logout_success"))
      end

      private

      def user_payload(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          is_admin: user.is_admin
        }
      end
    end
  end
end
