require 'rack'
require 'json'
require 'logger'

require_relative '../config/routes'
require_relative './helpers/gzip_helper'

class MainApp
  def initialize
    @logger = Logger.new($stdout)
  end

  def call(env)
    req = Rack::Request.new(env)
    accept_encoding = req.env['HTTP_ACCEPT_ENCODING']
    gzip = accept_encoding && accept_encoding.split(',').map(&:strip).include?('gzip')
    res = Rack::Response.new

    begin
      @logger.info "Request: #{req.request_method} #{req.path_info}"
      status, headers, body = Routes.call(env)
    rescue => e
      @logger.error "Error: #{e.class} - #{e.message}"
      status = 500
      headers = { 'content-type' => 'application/json' }
      body = [{ error: 'Internal Server Error' }.to_json]
    end

    if gzip && body && headers['content-type'] =~ /json|yaml|text/
      body = GzipHelper.compress(body)
      headers['content-encoding'] = 'gzip'
    end

    res.status = status || 200
    headers.each { |k, v| res[k] = v }
    body.each { |b| res.write(b) }
    res.finish
  end
end