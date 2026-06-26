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

        issued = JwtService.issue_for_user(user)
        render_success(
          data: {
            token: issued[:token],
            token_type: "Bearer",
            expires_in: JwtService.expiration_seconds,
            exp: issued[:exp],
            user: user_payload(user)
          },
          message: I18n.t("auth.login_success")
        )
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
