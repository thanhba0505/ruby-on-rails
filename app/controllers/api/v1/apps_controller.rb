module Api
  module V1
    class AppsController < BaseController
      before_action :authenticate_user!
      before_action :set_app, only: %i[show update]

      def index
        return unless authorize_permission!("apps.read")

        apps = App.order(:name)
        desktop_app_ids, taskbar_app_ids = current_user_app_placement_ids
        render_success(data: { apps: apps.map { |app| app_payload(app, desktop_app_ids:, taskbar_app_ids:) } })
      end

      def show
        return unless authorize_permission!("apps.read")

        desktop_app_ids, taskbar_app_ids = current_user_app_placement_ids
        render_success(data: { app: app_payload(@app, desktop_app_ids:, taskbar_app_ids:) })
      end

      def update
        return unless authorize_permission!("apps.update")

        @app.update!(app_params)
        desktop_app_ids, taskbar_app_ids = current_user_app_placement_ids
        render_success(
          data: { app: app_payload(@app, desktop_app_ids:, taskbar_app_ids:) },
          message: I18n.t("apps.updated")
        )
      end

      private

      def set_app
        @app = App.find(params[:id])
      end

      def app_params
        params.require(:app).permit(:name, :icon, :description, :is_active)
      end

      def current_user_app_placement_ids
        [
          current_user.user_desktop_apps.pluck(:app_id),
          current_user.user_taskbar_apps.pluck(:app_id)
        ]
      end

      def app_payload(app, desktop_app_ids:, taskbar_app_ids:)
        {
          id: app.id,
          code: app.code,
          name: app.name,
          icon: app.icon,
          description: app.description,
          is_active: app.is_active,
          placed_on_desktop: desktop_app_ids.include?(app.id),
          placed_on_taskbar: taskbar_app_ids.include?(app.id)
        }
      end
    end
  end
end
