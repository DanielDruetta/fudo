require 'rack'
require 'json'
require_relative './product_store'
require_relative './sidekiq_worker'

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

    when ['POST', '/products']
      token = req.get_header('HTTP_AUTHORIZATION')
      unless token == 'Bearer valid-token'
        res.status = 401
        res.write({ error: 'Unauthorized' }.to_json)
        return res.finish
      end
      params = JSON.parse(req.body.read)
      name = params['name']
      if name.nil? || name.strip.empty?
        res.status = 400
        res.write({ error: 'Name required' }.to_json)
        return res.finish
      end
      jid = ProductWorker.perform_async(name)
      res.status = 202
      res.write({ message: 'Product creation scheduled', job_id: jid }.to_json)

    when ['GET', '/products']
      token = req.get_header('HTTP_AUTHORIZATION')
      unless token == 'Bearer valid-token'
        res.status = 401
        res.write({ error: 'Unauthorized' }.to_json)
        return res.finish
      end
      products = ProductStore.all
      res.write(products.to_json)

    else
      res.status = 404
      res.write({ error: 'Not found' }.to_json)
    end

    res.finish
  end
end