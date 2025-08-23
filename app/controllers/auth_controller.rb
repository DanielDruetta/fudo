class AuthController
  def initialize(req)
    @req = req
  end

  def login
    params = JSON.parse(@req.body.read)
    if params['user'] == 'admin' && params['password'] == 'secret'
      [200, { 'content-type' => 'application/json' }, [{ token: 'valid-token' }.to_json]]
    else
      [401, { 'content-type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
    end
  end
end
