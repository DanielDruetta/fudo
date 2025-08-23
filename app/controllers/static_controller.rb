class StaticController
  def initialize(req)
    @req = req
  end

  def openapi
    serve_static_file('../../../openapi.yaml', 'application/yaml', 'no-store, no-cache, must-revalidate')
  end

  def authors
    serve_static_file('../../../AUTHORS', 'text/plain', 'public, max-age=86400')
  end

  private

  def serve_static_file(relative_path, content_type, cache_control)
    file_path = File.expand_path(relative_path, __FILE__)
    if File.exist?(file_path)
      [200, { 'content-type' => content_type, 'cache-control' => cache_control }, [File.read(file_path)]]
    else
      [404, { 'content-type' => 'application/json' }, [{ error: 'Not found' }.to_json]]
    end
  end
end
