class JwtService
  ALGORITHM = "HS256"

  class InvalidTokenError < StandardError; end
  class ExpiredTokenError < StandardError; end

  def self.issue_for_user(user)
    issue_access_token_for_user(user)
  end

  def self.issue_access_token_for_user(user)
    exp = Time.now.to_i + access_expiration_seconds
    token = encode({ sub: user.id, typ: "access" }, exp: exp)

    { token: token, exp: exp }
  end

  def self.issue_refresh_token_for_user(user)
    exp = Time.now.to_i + refresh_expiration_seconds
    jti = SecureRandom.uuid
    token = encode({ sub: user.id, typ: "refresh", jti: jti }, exp: exp)

    {
      token: token,
      exp: exp,
      jti: jti,
      token_digest: token_digest(token)
    }
  end

  def self.encode(payload, exp:)
    now = Time.now.to_i
    full_payload = payload.stringify_keys.merge("iat" => now, "exp" => exp.to_i)

    JWT.encode(full_payload, secret, ALGORITHM)
  end

  def self.decode(token)
    decoded, = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
    decoded
  rescue JWT::ExpiredSignature
    raise ExpiredTokenError
  rescue JWT::DecodeError, JWT::VerificationError
    raise InvalidTokenError
  end

  def self.decode_access(token)
    payload = decode(token)
    return payload if payload["typ"] == "access"

    raise InvalidTokenError
  end

  def self.decode_refresh(token)
    payload = decode(token)
    return payload if payload["typ"] == "refresh" && payload["jti"].present?

    raise InvalidTokenError
  end

  def self.expiration_seconds
    access_expiration_seconds
  end

  def self.access_expiration_seconds
    ENV.fetch("JWT_ACCESS_EXP_SECONDS", ENV.fetch("JWT_EXP_SECONDS", "86400")).to_i
  end

  def self.refresh_expiration_seconds
    ENV.fetch("JWT_REFRESH_EXP_SECONDS", "2592000").to_i
  end

  def self.token_digest(token)
    Digest::SHA256.hexdigest(token)
  end

  def self.secret
    ENV["JWT_SECRET"].presence ||
      Rails.application.credentials.dig(:jwt, :secret).presence ||
      Rails.application.secret_key_base
  end
end
