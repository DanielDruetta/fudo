require 'sidekiq'
require_relative './models/product'

class ProductWorker
  include Sidekiq::Worker

  def perform(name)
    sleep 5
    Product.create(name)
  end
end
