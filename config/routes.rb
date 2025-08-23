require_relative '../app/controllers/auth_controller'
require_relative '../app/controllers/product_controller'
require_relative '../app/controllers/static_controller'

class Routes
  def self.call(env)
    req = Rack::Request.new(env)

    case
    when req.request_method == 'POST' && req.path_info == '/auth'
      AuthController.new(req).login
    when req.request_method == 'GET' && req.path_info == '/products'
      ProductController.new(req).index
    when req.request_method == 'POST' && req.path_info == '/products'
      ProductController.new(req).create
    when req.request_method == 'PUT' && req.path_info.match(%r{^/products/\d+$})
      id = req.path_info.split('/').last
      ProductController.new(req).update(id)
    when req.request_method == 'GET' && req.path_info == '/openapi.yaml'
      StaticController.new(req).openapi
    when req.request_method == 'GET' && req.path_info == '/AUTHORS'
      StaticController.new(req).authors
    else
      [404, { 'content-type' => 'application/json' }, [{ error: 'Not found' }.to_json]]
    end
  end
end
