class StaticController
  def initialize(req)
    @req = req
  end

  def openapi
    file_path = File.expand_path('../../../openapi.yaml', __FILE__)
    if File.exist?(file_path)
      [200, { 'content-type' => 'application/yaml', 'cache-control' => 'no-store, no-cache, must-revalidate' }, [File.read(file_path)]]
    else
      [404, { 'content-type' => 'application/json' }, [{ error: 'Not found' }.to_json]]
    end
  end

  def authors
    file_path = File.expand_path('../../../AUTHORS', __FILE__)
    if File.exist?(file_path)
      [200, { 'content-type' => 'text/plain', 'cache-control' => 'public, max-age=86400' }, [File.read(file_path)]]
    else
      [404, { 'content-type' => 'application/json' }, [{ error: 'Not found' }.to_json]]
    end
  end
end
