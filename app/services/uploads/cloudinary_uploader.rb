module Uploads
  class CloudinaryUploader
    class Error < StandardError; end

    REQUIRED_ENV_KEYS = %w[
      CLOUDINARY_CLOUD_NAME
      CLOUDINARY_API_KEY
      CLOUDINARY_API_SECRET
    ].freeze

    def self.upload(...)
      new.upload(...)
    end

    def self.destroy(...)
      new.destroy(...)
    end

    def self.configured?
      REQUIRED_ENV_KEYS.all? { |key| ENV[key].present? }
    end

    def upload(file:, folder: nil, resource_type: :image, public_id: nil, tags: [], **options)
      validate_configuration!
      source = upload_source(file)
      normalized_folder = normalized_folder(folder)

      response = Cloudinary::Uploader.upload(
        source,
        {
          folder: normalized_folder,
          resource_type: resource_type,
          public_id: public_id,
          tags: Array(tags),
          overwrite: true,
          use_filename: true,
          unique_filename: true,
          filename_override: original_filename(file)
        }.compact.merge(options)
      )

      normalize_response(response, file, normalized_folder)
    rescue CloudinaryException => e
      raise Error, e.message
    rescue StandardError => e
      raise Error, e.message
    end

    def destroy(public_id:, resource_type: :image, invalidate: true, **options)
      return if public_id.blank? || !self.class.configured?

      Cloudinary::Uploader.destroy(
        public_id,
        {
          resource_type: resource_type,
          invalidate: invalidate
        }.merge(options).compact
      )
    rescue CloudinaryException, StandardError => e
      Rails.logger.warn("Cloudinary destroy failed for #{public_id}: #{e.message}")
      nil
    end

    private

    def validate_configuration!
      return if self.class.configured?

      raise Error, "Missing Cloudinary configuration"
    end

    def upload_source(file)
      return file.tempfile if file.respond_to?(:tempfile)
      return file if file.respond_to?(:read)
      return file.to_path if file.respond_to?(:to_path)

      raise Error, "Invalid upload file"
    end

    def original_filename(file)
      return file.original_filename if file.respond_to?(:original_filename)
      return File.basename(file.path) if file.respond_to?(:path)

      "upload"
    end

    def normalized_folder(folder)
      segments = [ ENV["CLOUDINARY_UPLOAD_FOLDER"].presence, folder.presence ].compact
      return if segments.empty?

      segments.join("/").gsub(%r{/+}, "/")
    end

    def normalize_response(response, file, folder)
      {
        "provider" => "cloudinary",
        "public_id" => response["public_id"],
        "resource_type" => response["resource_type"],
        "format" => response["format"],
        "bytes" => response["bytes"],
        "width" => response["width"],
        "height" => response["height"],
        "folder" => folder,
        "url" => response["url"],
        "secure_url" => response["secure_url"].presence || response["url"],
        "version" => response["version"],
        "original_filename" => original_filename(file),
        "content_type" => file.respond_to?(:content_type) ? file.content_type : nil,
        "metadata" => {
          "version" => response["version"],
          "uploaded_at" => Time.current.iso8601
        }.compact
      }.compact
    end
  end
end
