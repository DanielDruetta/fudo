require 'redis'
require 'json'

class Product
  def self.redis
    @redis ||= Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
  end

  def self.create(name)
    id = redis.incr('product:id')
    redis.hset('products', id, { id: id, name: name }.to_json)
    { id: id, name: name }
  end

  def self.all
    redis.hvals('products').map { |p| JSON.parse(p) }
  end

  def self.update(id, name)
    prod_json = redis.hget('products', id)
    return nil unless prod_json
    prod = JSON.parse(prod_json)
    prod['name'] = name
    redis.hset('products', id, prod.to_json)
    prod
  end
end
