require 'json'
require_relative '../../config/initializers/redis'

class Product
  def self.create(name)
    id = REDIS.incr('product:id')
    REDIS.hset('products', id, { id: id, name: name }.to_json)
    { id: id, name: name }
  end

  def self.all
    REDIS.hvals('products').map { |p| JSON.parse(p) }
  end

  def self.update(id, name)
    prod_json = REDIS.hget('products', id)
    return nil unless prod_json
    prod = JSON.parse(prod_json)
    prod['name'] = name
    REDIS.hset('products', id, prod.to_json)
    prod
  end
end
