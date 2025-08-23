require 'sidekiq'
require_relative './product_store'

class ProductWorker
  include Sidekiq::Worker

  def perform(name)
    sleep 5
    ProductStore.add(name)
  end
end
