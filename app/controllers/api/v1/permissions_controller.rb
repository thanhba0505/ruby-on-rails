module Api
  module V1
    class PermissionsController < BaseController
      before_action :authenticate_user!
      before_action :set_permission, only: %i[show update destroy]

      def index
        return unless authorize_permission!("permissions.read")

        permissions = Permission.order(:key)
        render_success(data: { permissions: permissions.map { |p| permission_payload(p) } })
      end

      def show
        return unless authorize_permission!("permissions.read")

        render_success(data: { permission: permission_payload(@permission) })
      end

      def create
        return unless authorize_permission!("permissions.create")

        permission = Permission.new(permission_params)
        permission.save!
        render_success(data: { permission: permission_payload(permission) }, message: I18n.t("permissions.created"), status: :created)
      end

      def update
        return unless authorize_permission!("permissions.update")

        @permission.update!(permission_params)
        render_success(data: { permission: permission_payload(@permission) }, message: I18n.t("permissions.updated"))
      end

      def destroy
        return unless authorize_permission!("permissions.delete")

        @permission.destroy!
        render_success(data: { id: @permission.id }, message: I18n.t("permissions.deleted"))
      end

      private

      def set_permission
        @permission = Permission.find(params[:id])
      end

      def permission_params
        params.require(:permission).permit(:key, :value, :description)
      end

      def permission_payload(permission)
        {
          id: permission.id,
          key: permission.key,
          value: permission.value,
          description: permission.description
        }
      end
    end
  end
end
