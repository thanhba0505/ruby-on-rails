module Api
  module V1
    class MeController < BaseController
      before_action :authenticate_user!

      def show
        render_success(data: { user: user_payload(current_user) })
      end

      def update
        profile_attrs = me_update_params
        previous_files = {
          "avatar" => current_user.avatar,
          "background" => current_user.background
        }.compact
        uploaded_files = {}
        files_to_remove = {}

        upload_profile_assets(profile_attrs, uploaded_files)
        apply_profile_asset_changes(profile_attrs, previous_files, uploaded_files, files_to_remove)

        current_user.assign_attributes(name: profile_attrs[:name]) if profile_attrs.key?(:name)
        current_user.save!

        cleanup_removed_files(files_to_remove)
        render_success(data: { user: user_payload(current_user.reload) }, message: I18n.t("users.updated"))
      rescue ActiveRecord::RecordInvalid, Uploads::CloudinaryUploader::Error
        cleanup_uploaded_files(uploaded_files || {})
        raise
      end

      private

      def me_update_params
        params.require(:user).permit(:name, :avatar, :background, :remove_avatar, :remove_background)
      end

      def upload_profile_assets(profile_attrs, uploaded_files)
        %w[avatar background].each do |asset_key|
          uploaded_file = upload_asset(profile_attrs[asset_key], asset_key)
          uploaded_files[asset_key] = uploaded_file if uploaded_file.present?
        end
      end

      def upload_asset(file, asset_key)
        return if file.blank?

        folder_key = {
          "avatar" => :user_avatar,
          "background" => :user_background
        }.fetch(asset_key)

        uploaded_asset = Uploads::CloudinaryUploader.upload(
          file: file,
          folder: Uploads::FolderConfig.resolve(folder_key, user_id: current_user.id),
          tags: [ "user-profile", asset_key, "user-#{current_user.id}" ]
        )

        UploadedFile.create_from_upload!(uploaded_asset)
      end

      def apply_profile_asset_changes(profile_attrs, previous_files, uploaded_files, files_to_remove)
        {
          "avatar" => boolean_param(profile_attrs[:remove_avatar]),
          "background" => boolean_param(profile_attrs[:remove_background])
        }.each do |asset_key, remove_requested|
          previous_file = previous_files[asset_key]
          uploaded_file = uploaded_files[asset_key]

          if uploaded_file.present?
            current_user.public_send("#{asset_key}=", uploaded_file)
            files_to_remove[asset_key] = previous_file if previous_file.present? && previous_file.id != uploaded_file.id
            next
          end

          next unless remove_requested

          current_user.public_send("#{asset_key}=", nil)
          files_to_remove[asset_key] = previous_file if previous_file.present?
        end
      end

      def cleanup_uploaded_files(uploaded_files)
        return if uploaded_files.blank?

        uploaded_files.each_value do |uploaded_file|
          next if uploaded_file.blank?

          soft_delete_uploaded_file(uploaded_file, reason: "rollback_update_me")
        end
      end

      def cleanup_removed_files(files_to_remove)
        files_to_remove.each_value do |uploaded_file|
          next if uploaded_file.blank?

          soft_delete_uploaded_file(uploaded_file, reason: "removed_from_profile")
        end
      end

      def soft_delete_uploaded_file(uploaded_file, reason:)
        uploaded_file.soft_delete!(reason: reason)
      end

      def boolean_param(value)
        ActiveModel::Type::Boolean.new.cast(value)
      end

      def user_payload(user)
        UserPayloadBuilder.build(user, include_roles: true, include_permissions: true)
      end
    end
  end
end
