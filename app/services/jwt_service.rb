class JwtService
  ALGORITHM = "HS256"

  class InvalidTokenError < StandardError; end
  class ExpiredTokenError < StandardError; end

  def self.issue_for_user(user)
    exp = Time.now.to_i + expiration_seconds
    token = encode({ sub: user.id }, exp: exp)

    { token: token, exp: exp }
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

  def self.expiration_seconds
    ENV.fetch("JWT_EXP_SECONDS", "86400").to_i
  end

  def self.secret
    ENV["JWT_SECRET"].presence ||
      Rails.application.credentials.dig(:jwt, :secret).presence ||
      Rails.application.secret_key_base
  end
end
