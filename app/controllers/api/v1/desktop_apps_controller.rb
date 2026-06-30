module Api
  module V1
    class DesktopAppsController < BaseController
      before_action :authenticate_user!

      def index
        desktop_apps = current_user.user_desktop_apps.includes(:app).order(:grid_y, :grid_x)
        render_success(data: { desktop_apps: desktop_apps.map { |record| desktop_app_payload(record) } })
      end

      def create
        attrs = desktop_app_create_params
        app_id = attrs.fetch(:app_id).to_i
        grid_x = Integer(attrs.fetch(:grid_x))
        grid_y = Integer(attrs.fetch(:grid_y))

        if current_user.user_desktop_apps.where(grid_x: grid_x, grid_y: grid_y).where.not(app_id: app_id).exists?
          return render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
        end

        record = current_user.user_desktop_apps.find_or_initialize_by(app_id: app_id)
        record.grid_x = grid_x
        record.grid_y = grid_y
        record.save!

        render_success(data: { desktop_app: desktop_app_payload(record.reload) }, status: :created)
      rescue ActionController::ParameterMissing, KeyError, TypeError, ArgumentError
        render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
      end

      def update
        record = current_user.user_desktop_apps.find_by!(app_id: params[:app_id])

        attrs = desktop_app_update_params
        grid_x = Integer(attrs.fetch(:grid_x))
        grid_y = Integer(attrs.fetch(:grid_y))

        if current_user.user_desktop_apps.where(grid_x: grid_x, grid_y: grid_y).where.not(app_id: record.app_id).exists?
          return render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
        end

        record.update!(grid_x: grid_x, grid_y: grid_y)
        render_success(data: { desktop_app: desktop_app_payload(record.reload) })
      rescue ActionController::ParameterMissing, KeyError, TypeError, ArgumentError
        render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
      end

      def destroy
        record = current_user.user_desktop_apps.find_by!(app_id: params[:app_id])
        record.destroy!
        render_success(data: { app_id: record.app_id })
      end

      def positions
        updates = Array(params.require(:desktop_apps))

        app_ids = updates.map { |item| item.fetch(:app_id) }.map(&:to_i).uniq
        records = current_user.user_desktop_apps.where(app_id: app_ids).index_by(&:app_id)

        if records.size != app_ids.size
          return render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
        end

        grid_positions = current_user.user_desktop_apps.pluck(:app_id, :grid_x, :grid_y).to_h do |app_id, grid_x, grid_y|
          [ app_id, [ grid_x, grid_y ] ]
        end

        updates.each do |item|
          app_id = item.fetch(:app_id).to_i
          grid_x = Integer(item.fetch(:grid_x))
          grid_y = Integer(item.fetch(:grid_y))
          grid_positions[app_id] = [ grid_x, grid_y ]
        end

        positions_only = grid_positions.values
        if positions_only.uniq.size != positions_only.size
          return render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
        end

        ActiveRecord::Base.transaction do
          updates.each do |item|
            app_id = item.fetch(:app_id).to_i
            record = records.fetch(app_id)
            record.update!(grid_x: Integer(item.fetch(:grid_x)), grid_y: Integer(item.fetch(:grid_y)))
          end
        end

        desktop_apps = current_user.user_desktop_apps.includes(:app).order(:grid_y, :grid_x)
        render_success(data: { desktop_apps: desktop_apps.map { |record| desktop_app_payload(record) } })
      rescue ActionController::ParameterMissing, KeyError, TypeError, ArgumentError
        render_error(message: I18n.t("common.invalid_params"), errors: [ "Unprocessable Entity" ], status: :unprocessable_entity)
      end

      private

      def desktop_app_create_params
        params.require(:desktop_app).permit(:app_id, :grid_x, :grid_y)
      end

      def desktop_app_update_params
        params.require(:desktop_app).permit(:grid_x, :grid_y)
      end

      def desktop_app_payload(record)
        {
          id: record.id,
          app: app_payload(record.app),
          grid_x: record.grid_x,
          grid_y: record.grid_y
        }
      end

      def app_payload(app)
        {
          id: app.id,
          code: app.code,
          name: app.name,
          icon: app.icon,
          description: app.description,
          is_active: app.is_active
        }
      end
    end
  end
end
