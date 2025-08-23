require 'rack'
require 'json'
require_relative './product_store'
require_relative './sidekiq_worker'

class MainApp
  def call(env)
    req = Rack::Request.new(env)
    gzip = req.env['HTTP_ACCEPT_ENCODING']&.include?('gzip')
    res = Rack::Response.new
    res['content-type'] = 'application/json'

    body = nil
    status = nil

    case [req.request_method, req.path_info]
    when ['POST', '/auth']
      params = JSON.parse(req.body.read)
      if params['user'] == 'admin' && params['password'] == 'secret'
        body = { token: 'valid-token' }.to_json
        status = 200
      else
        body = { error: 'Unauthorized' }.to_json
        status = 401
      end

    when ['POST', '/products']
      token = req.get_header('HTTP_AUTHORIZATION')
      unless token == 'Bearer valid-token'
        body = { error: 'Unauthorized' }.to_json
        status = 401
      else
        params = JSON.parse(req.body.read)
        name = params['name']
        if name.nil? || name.strip.empty?
          body = { error: 'Name required' }.to_json
          status = 400
        else
          jid = ProductWorker.perform_async(name)
          body = { message: 'Product creation scheduled', job_id: jid }.to_json
          status = 202
        end
      end

    when ['GET', '/products']
      token = req.get_header('HTTP_AUTHORIZATION')
      unless token == 'Bearer valid-token'
        body = { error: 'Unauthorized' }.to_json
        status = 401
      else
        products = ProductStore.all
        body = products.to_json
        status = 200
      end

    when ['GET', '/openapi.yaml']
      file_path = File.expand_path('../../openapi.yaml', __FILE__)
      if File.exist?(file_path)
        res.status = 200
        res['content-type'] = 'application/yaml'
        res['cache-control'] = 'no-store, no-cache, must-revalidate'
        file_content = File.read(file_path)
        if gzip && file_content
          require 'stringio'
          require 'zlib'
          io = StringIO.new
          gz = Zlib::GzipWriter.new(io)
          gz.write(file_content)
          gz.close
          file_content = io.string
          res['content-encoding'] = 'gzip'
        end
        res.write(file_content)
      else
        res.status = 404
        res.write({ error: 'Not found' }.to_json)
      end
      return res.finish
    
    when ['GET', '/AUTHORS']
      file_path = File.expand_path('../../AUTHORS', __FILE__)
      if File.exist?(file_path)
        res.status = 200
        res['content-type'] = 'text/plain'
        res['cache-control'] = 'public, max-age=86400'
        res.write(File.read(file_path))
      else
        res.status = 404
        res.write({ error: 'Not found' }.to_json)
      end
      return res.finish
    
    else
      body = { error: 'Not found' }.to_json
      status = 404
    end

    if gzip && body
      require 'stringio'
      require 'zlib'
      io = StringIO.new
      gz = Zlib::GzipWriter.new(io)
      gz.write(body)
      gz.close
      body = io.string
      res['content-encoding'] = 'gzip'
    end

    res.status = status || 200
    res.write(body)
    res.finish
  end
end