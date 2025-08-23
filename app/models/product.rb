require 'json'
require_relative '../../config/initializers/redis'

class Product
  PRODUCTS_KEY = 'products'.freeze
  PRODUCT_ID_KEY = 'product:id'.freeze

  def self.all
    REDIS.hvals(PRODUCTS_KEY).map { |p| JSON.parse(p) rescue nil }.compact
  end

  def self.create(name)
    return nil if !valid_name?(name)
    id = REDIS.incr(PRODUCT_ID_KEY)
    prod_hash = { id: id, name: name }
    REDIS.hset(PRODUCTS_KEY, id, prod_hash.to_json)
    prod_hash
  end
  
  def self.update(id, name)
    return nil unless valid_name?(name)
    prod_json = REDIS.hget(PRODUCTS_KEY, id)
    return nil unless prod_json
    prod = JSON.parse(prod_json) rescue nil
    return nil unless prod
    prod['name'] = name
    REDIS.hset(PRODUCTS_KEY, id, prod.to_json)
    prod
  end

  private

  def self.valid_name?(name)
    name.is_a?(String) && !name.strip.empty?
  end
end
