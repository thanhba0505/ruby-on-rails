module Uploads
  module FolderConfig
    FOLDERS = {
      user_avatar: "users/%{user_id}/avatar",
      user_background: "users/%{user_id}/background"
    }.freeze

    def self.resolve(key, **variables)
      template = FOLDERS.fetch(key.to_sym) do
        raise ArgumentError, "Unknown upload folder key: #{key}"
      end

      format(template, variables.transform_keys(&:to_sym))
    rescue KeyError => e
      raise ArgumentError, "Missing upload folder variable: #{e.key}"
    end
  end
end
