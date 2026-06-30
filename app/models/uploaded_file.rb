class UploadedFile < ApplicationRecord
  scope :active, -> { where(deleted_at: nil) }

  has_many :avatar_users, class_name: "User", foreign_key: :avatar_id, inverse_of: :avatar
  has_many :background_users, class_name: "User", foreign_key: :background_id, inverse_of: :background

  validates :provider, :public_id, :resource_type, :secure_url, presence: true
  validates :public_id, uniqueness: { scope: :provider }

  def self.create_from_upload!(payload)
    metadata = payload.fetch("metadata", {})

    create!(
      provider: payload.fetch("provider", "cloudinary"),
      public_id: payload.fetch("public_id"),
      resource_type: payload.fetch("resource_type"),
      format: payload["format"],
      bytes: payload["bytes"],
      width: payload["width"],
      height: payload["height"],
      original_filename: payload["original_filename"],
      content_type: payload["content_type"],
      folder: payload["folder"],
      url: payload["url"],
      secure_url: payload.fetch("secure_url"),
      metadata: metadata
    )
  end

  def file_url
    secure_url.presence || url
  end

  def deleted?
    deleted_at.present?
  end

  def still_referenced?
    avatar_users.exists? || background_users.exists?
  end

  def soft_delete!(reason: nil)
    return if deleted?
    return if still_referenced?

    Uploads::CloudinaryUploader.destroy(
      public_id: public_id,
      resource_type: resource_type
    )

    updated_metadata = metadata.deep_dup
    updated_metadata["deleted_reason"] = reason if reason.present?
    updated_metadata["deleted_from_cloud_at"] = Time.current.iso8601

    update!(
      deleted_at: Time.current,
      metadata: updated_metadata
    )
  end

  def payload
    {
      id: id,
      provider: provider,
      public_id: public_id,
      resource_type: resource_type,
      format: format,
      bytes: bytes,
      width: width,
      height: height,
      original_filename: original_filename,
      content_type: content_type,
      folder: folder,
      url: url,
      secure_url: secure_url,
      metadata: metadata,
      deleted_at: deleted_at
    }.compact
  end
end
