module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_user!
      before_action :set_user, only: %i[show update destroy roles]

      def index
        return unless authorize_permission!("users.read")

        users = User.order(id: :desc).includes(:roles)
        render_success(data: { users: users.map { |u| user_payload(u) } })
      end

      def show
        return unless authorize_permission!("users.read")

        render_success(data: { user: user_payload(@user) })
      end

      def create
        return unless authorize_permission!("users.create")

        user = User.new(user_create_params)
        user.save!
        render_success(data: { user: user_payload(user) }, message: I18n.t("users.created"), status: :created)
      end

      def update
        return unless authorize_permission!("users.update")

        if @user.is_admin && admin_user_forbidden_update?
          return render_error(
            message: I18n.t("users.admin_readonly"),
            errors: [ "Unprocessable Entity" ],
            status: :unprocessable_entity
          )
        end

        @user.assign_attributes(user_update_params)
        assign_settings_attributes(@user, user_settings_params)
        @user.save!
        render_success(data: { user: user_payload(@user) }, message: I18n.t("users.updated"))
      end

      def destroy
        return unless authorize_permission!("users.delete")

        if @user.is_admin
          return render_error(
            message: I18n.t("users.admin_cannot_delete"),
            errors: [ "Unprocessable Entity" ],
            status: :unprocessable_entity
          )
        end

        @user.destroy!
        render_success(data: { id: @user.id }, message: I18n.t("users.deleted"))
      end

      def roles
        return unless authorize_permission!("users.assign_roles")

        role_ids = Array(params.require(:role_ids)).map(&:to_i).uniq
        roles = Role.where(id: role_ids)
        if roles.size != role_ids.size
          return render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
        end

        if @user.is_admin && roles.none?(&:is_admin)
          return render_error(
            message: I18n.t("users.admin_requires_admin_role"),
            errors: [ "Unprocessable Entity" ],
            status: :unprocessable_entity
          )
        end

        @user.roles = roles
        render_success(data: { user: user_payload(@user.reload) }, message: I18n.t("permission.role_assigned"))
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_create_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, settings: [ :icon_size ])
      end

      def user_update_params
        permitted = params.require(:user).permit(:name, :email, :password, :password_confirmation)
        return permitted unless @user.is_admin

        permitted.slice(:password, :password_confirmation)
      end

      def user_settings_params
        params.fetch(:user, ActionController::Parameters.new).permit(settings: [ :icon_size ]).fetch(:settings, {})
      end

      def admin_user_forbidden_update?
        incoming = params.require(:user).permit(:name, :email, :password, :password_confirmation)
        incoming.key?(:name) || incoming.key?(:email)
      end

      def assign_settings_attributes(user, settings_attrs)
        return if settings_attrs.blank?

        user.icon_size = settings_attrs[:icon_size] if settings_attrs.key?(:icon_size)
      end

      def user_payload(user)
        UserPayloadBuilder.build(user, include_roles: true)
      end
    end
  end
end
