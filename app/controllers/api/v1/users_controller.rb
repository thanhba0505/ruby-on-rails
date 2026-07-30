module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_user!
      before_action :require_admin!
      before_action :set_user, only: %i[show update destroy]

      def index
        users = User.order(id: :desc)
        render_success(data: { users: users.map { |u| user_payload(u) } })
      end

      def show
        render_success(data: { user: user_payload(@user) })
      end

      def create
        user = User.new(user_create_params)
        user.save!
        render_success(data: { user: user_payload(user) }, message: I18n.t("users.created"), status: :created)
      end

      def update
        if @user.bootstrap_admin? && admin_user_forbidden_update?
          return render_error(
            message: I18n.t("users.admin_readonly"),
            errors: [ "Unprocessable Entity" ],
            status: :unprocessable_entity
          )
        end

        @user.update!(user_update_params)
        render_success(data: { user: user_payload(@user) }, message: I18n.t("users.updated"))
      end

      def destroy
        if @user.bootstrap_admin?
          return render_error(
            message: I18n.t("users.admin_cannot_delete"),
            errors: [ "Unprocessable Entity" ],
            status: :unprocessable_entity
          )
        end

        @user.destroy!
        render_success(data: { id: @user.id }, message: I18n.t("users.deleted"))
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_create_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def user_update_params
        permitted = params.require(:user).permit(:name, :email, :password, :password_confirmation)
        return permitted unless @user.bootstrap_admin?

        permitted.slice(:password, :password_confirmation)
      end

      def admin_user_forbidden_update?
        incoming = params.require(:user).permit(:name, :email, :password, :password_confirmation)
        incoming.key?(:name) || incoming.key?(:email)
      end

      def user_payload(user)
        {
          id: user.id,
          name: user.name,
          email: user.email
        }
      end
    end
  end
end
