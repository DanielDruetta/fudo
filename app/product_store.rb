require 'json'
require_relative '../config/initializers/redis'

class ProductStore
  def self.add(name)
    id = REDIS.incr('product:id')
    REDIS.hset('products', id, { id: id, name: name }.to_json)
    id
  end

  def self.all
    REDIS.hvals('products').map { |p| JSON.parse(p) }
  end
end
