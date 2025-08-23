require_relative '../services/product_service'

class ProductController
  def initialize(req)
    @req = req
  end

  def index
    return unauthorized_response unless token_valid?

    products = ProductService.all
    [200, { 'content-type' => 'application/json' }, [products.to_json]]
  end
  
  def create
    return unauthorized_response unless token_valid?

    params = JSON.parse(@req.body.read)
    name = params['name']
    return [400, { 'content-type' => 'application/json' }, [{ error: 'Name required' }.to_json]] if name.nil? || name.strip.empty?

    jid = ProductService.create_async(name)
    [202, { 'content-type' => 'application/json' }, [{ message: 'Product creation scheduled', job_id: jid }.to_json]]
  end

  def update(id)
    return unauthorized_response unless token_valid?

    params = JSON.parse(@req.body.read)
    name = params['name']
    return [400, { 'content-type' => 'application/json' }, [{ error: 'Name required' }.to_json]] if name.nil? || name.strip.empty?

    prod = ProductService.update(id, name)
    if prod
      [200, { 'content-type' => 'application/json' }, [prod.to_json]]
    else
      [404, { 'content-type' => 'application/json' }, [{ error: 'Product not found' }.to_json]]
    end
  end

  private

  def token_valid?
    @req.get_header('HTTP_AUTHORIZATION') == 'Bearer valid-token'
  end

  def unauthorized_response
    [401, { 'content-type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
  end
end
