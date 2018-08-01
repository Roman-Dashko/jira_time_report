class JsonWebToken
  def self.encode(claim,shared_secret)
    JWT.encode(claim,shared_secret)
  end

  def self.decode(token)
    return HashWithIndifferentAccess.new(JWT.decode(token, Rails.application.secrets.secret_key_base)[0])
  rescue
    nil
  end
end