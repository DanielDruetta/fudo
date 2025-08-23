
require 'rack'
require 'json'
require_relative './controllers/auth_controller'
require_relative './controllers/product_controller'
require_relative './controllers/static_controller'

class MainApp
  def call(env)
    req = Rack::Request.new(env)
    gzip = req.env['HTTP_ACCEPT_ENCODING']&.include?('gzip')
    res = Rack::Response.new

    # Rutas principales
    case
    when req.request_method == 'POST' && req.path_info == '/auth'
      status, headers, body = AuthController.new(req).login
    when req.request_method == 'POST' && req.path_info == '/products'
      status, headers, body = ProductController.new(req).create
    when req.request_method == 'GET' && req.path_info == '/products'
      status, headers, body = ProductController.new(req).index
    when req.request_method == 'PUT' && req.path_info.match(%r{^/products/\d+$})
      id = req.path_info.split('/').last
      status, headers, body = ProductController.new(req).update(id)
    when req.request_method == 'GET' && req.path_info == '/openapi.yaml'
      status, headers, body = StaticController.new(req).openapi
    when req.request_method == 'GET' && req.path_info == '/AUTHORS'
      status, headers, body = StaticController.new(req).authors
    else
      status = 404
      headers = { 'content-type' => 'application/json' }
      body = [{ error: 'Not found' }.to_json]
    end

    # Gzip para respuestas JSON/YAML/text si el cliente lo solicita
    if gzip && body && headers['content-type'] =~ /json|yaml|text/
      require 'stringio'
      require 'zlib'
      gz_body = body.map do |b|
        io = StringIO.new
        gz = Zlib::GzipWriter.new(io)
        gz.write(b)
        gz.close
        io.string
      end
      body = gz_body
      headers['content-encoding'] = 'gzip'
    end

    res.status = status || 200
    headers.each { |k, v| res[k] = v }
    body.each { |b| res.write(b) }
    res.finish
  end
end