module Api
  module V1
    class RolesController < BaseController
      before_action :authenticate_user!
      before_action :set_role, only: %i[show update destroy permissions]

      def index
        return unless authorize_permission!("roles.read")

        roles = Role.order(id: :desc).includes(:permissions)
        render_success(data: { roles: roles.map { |r| role_payload(r) } })
      end

      def show
        return unless authorize_permission!("roles.read")

        render_success(data: { role: role_payload(@role) })
      end

      def create
        return unless authorize_permission!("roles.create")

        role = Role.new(role_params)
        role.save!
        render_success(data: { role: role_payload(role) }, message: I18n.t("roles.created"), status: :created)
      end

      def update
        return unless authorize_permission!("roles.update")

        if @role.is_admin && admin_role_forbidden_update?
          return render_error(
            message: I18n.t("roles.admin_readonly"),
            errors: [ "Unprocessable Entity" ],
            status: :unprocessable_entity
          )
        end

        @role.update!(role_params)
        render_success(data: { role: role_payload(@role) }, message: I18n.t("roles.updated"))
      end

      def destroy
        return unless authorize_permission!("roles.delete")

        if @role.is_admin
          return render_error(
            message: I18n.t("roles.admin_cannot_delete"),
            errors: [ "Unprocessable Entity" ],
            status: :unprocessable_entity
          )
        end

        @role.destroy!
        render_success(data: { id: @role.id }, message: I18n.t("roles.deleted"))
      end

      def permissions
        return unless authorize_permission!("roles.assign_permissions")

        permission_ids = Array(params.require(:permission_ids)).map(&:to_i).uniq
        permissions = Permission.where(id: permission_ids)
        if permissions.size != permission_ids.size
          return render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
        end

        if @role.is_admin && permissions.empty?
          return render_error(
            message: I18n.t("roles.admin_requires_permissions"),
            errors: [ "Unprocessable Entity" ],
            status: :unprocessable_entity
          )
        end

        @role.permissions = permissions
        render_success(data: { role: role_payload(@role.reload) }, message: I18n.t("permission.permission_assigned"))
      end

      private

      def set_role
        @role = Role.find(params[:id])
      end

      def role_params
        params.require(:role).permit(:name, :code, :description)
      end

      def admin_role_forbidden_update?
        incoming = params.require(:role).permit(:name, :code, :description)
        incoming.key?(:name) || incoming.key?(:code)
      end

      def role_payload(role)
        {
          id: role.id,
          name: role.name,
          code: role.code,
          description: role.description,
          is_admin: role.is_admin,
          permissions: role.permissions.select(:id, :key, :value).map(&:attributes)
        }
      end
    end
  end
end
