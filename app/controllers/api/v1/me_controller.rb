module Api
  module V1
    class MeController < BaseController
      before_action :authenticate_user!

      def show
        render_success(
          data: {
            user: {
              id: current_user.id,
              name: current_user.name,
              email: current_user.email,
              is_admin: current_user.is_admin,
              roles: current_user.roles.select(:id, :name, :code, :is_admin).map(&:attributes),
              permissions: current_user.permissions.pluck(:key).sort
            }
          }
        )
      end
    end
  end
end
