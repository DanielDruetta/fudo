require 'redis'
require 'json'

class ProductStore
  def self.redis
    @redis ||= Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
  end

  def self.add(name)
    id = redis.incr('product:id')
    redis.hset('products', id, { id: id, name: name }.to_json)
    id
  end

  def self.all
    redis.hvals('products').map { |p| JSON.parse(p) }
  end
end
