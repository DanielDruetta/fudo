require 'bcrypt'
require 'securerandom'
require_relative '../../config/initializers/redis'

class AuthController
  def initialize(req)
    @req = req
  end

  def login
    begin
      params = parse_json(@req.body.read)
    rescue JSON::ParserError
      return [400, { 'content-type' => 'application/json' }, [{ error: 'Invalid JSON' }.to_json]]
    end

    unless valid_params?(params)
      return [400, { 'content-type' => 'application/json' }, [{ error: 'Invalid parameters' }.to_json]]
    end

    if authenticate(params['user'], params['password'])
      token = generate_token(params['user'])
      [200, { 'content-type' => 'application/json' }, [{ token: token }.to_json]]
    else
      [401, { 'content-type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
    end
  end

  def self.create_user(username, password)
    return false unless username.is_a?(String) && password.is_a?(String) && !username.empty? && !password.empty?
    pass_hash = BCrypt::Password.create(password)
    REDIS.set("users:#{username}", pass_hash)
    true
  end

  private

  def parse_json(body)
    JSON.parse(body)
  end

  def valid_params?(params)
    params.is_a?(Hash) && params['user'].is_a?(String) && params['password'].is_a?(String)
  end

  def authenticate(user, password)
    pass_hash = REDIS.get("users:#{user}")
    return false unless pass_hash
    BCrypt::Password.new(pass_hash) == password
  end

  def generate_token(user)
    token = SecureRandom.hex(32)
    REDIS.setex("tokens:#{token}", 3600, user) # Persist token for 1 hour
    token
  end
end
