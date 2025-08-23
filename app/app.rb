
require 'rack'
require 'json'

require_relative './routes'

class MainApp
  def call(env)
    req = Rack::Request.new(env)
    gzip = req.env['HTTP_ACCEPT_ENCODING']&.include?('gzip')
    res = Rack::Response.new

    status, headers, body = Routes.call(env)

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