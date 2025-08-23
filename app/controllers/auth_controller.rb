class AuthController
  def initialize(req)
    @req = req
  end

  def login
    params = parse_json(@req.body.read)
    unless valid_params?(params)
      return [400, { 'content-type' => 'application/json' }, [{ error: 'Invalid parameters' }.to_json]]
    end

    if authenticate(params['user'], params['password'])
      [200, { 'content-type' => 'application/json' }, [{ token: 'valid-token' }.to_json]]
    else
      [401, { 'content-type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
    end
  end

  private

  def parse_json(body)
    JSON.parse(body) rescue nil
  end

  def valid_params?(params)
    params.is_a?(Hash) && params['user'].is_a?(String) && params['password'].is_a?(String)
  end

  def authenticate(user, password)
    user == 'admin' && password == 'secret'
  end
end
