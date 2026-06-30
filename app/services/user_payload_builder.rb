class UserPayloadBuilder
  def self.build(user, include_roles: false, include_permissions: false)
    new(user, include_roles:, include_permissions:).build
  end

  def initialize(user, include_roles:, include_permissions:)
    @user = user
    @include_roles = include_roles
    @include_permissions = include_permissions
  end

  def build
    payload = {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      is_admin: @user.is_admin,
      avatar_id: @user.avatar_id,
      avatar: file_payload(@user.avatar),
      avatar_url: file_url(@user.avatar),
      background_id: @user.background_id,
      background: file_payload(@user.background),
      background_url: file_url(@user.background)
    }

    payload[:roles] = roles_payload if @include_roles
    payload[:permissions] = permissions_payload if @include_permissions
    payload
  end

  private

  def file_payload(file)
    return if file&.deleted?

    file&.payload
  end

  def file_url(file)
    return if file&.deleted?

    file&.file_url
  end

  def roles_payload
    @user.roles.select(:id, :name, :code, :is_admin).map(&:attributes)
  end

  def permissions_payload
    @user.permissions.pluck(:key).sort
  end
end
