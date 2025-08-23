require 'rack'
require 'json'

class MainApp
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    res['Content-Type'] = 'application/json'

    case [req.request_method, req.path_info]
    when ['POST', '/auth']
      params = JSON.parse(req.body.read)
      if params['user'] == 'admin' && params['password'] == 'secret'
        res.write({ token: 'valid-token' }.to_json)
      else
        res.status = 401
        res.write({ error: 'Unauthorized' }.to_json)
      end

    else
      res.status = 404
      res.write({ error: 'Not found' }.to_json)
    end

    res.finish
  end
end