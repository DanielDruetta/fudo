require_relative '../models/product'
require_relative '../workers/sidekiq_worker'

class ProductService
  def self.create_async(name)
    ProductWorker.perform_async(name)
  end

  def self.all
    Product.all
  end

  def self.update(id, name)
    Product.update(id, name)
  end
end
