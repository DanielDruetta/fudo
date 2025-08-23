require 'json'
require_relative '../../config/initializers/redis'

class Product
  attr_reader :id, :name

  PRODUCTS_KEY = 'products'.freeze
  PRODUCT_ID_KEY = 'product:id'.freeze

  def initialize(id:, name:)
    @id = id
    @name = name
  end

  def to_h
    { id: id, name: name }
  end

  def to_json(*_args)
    to_h.to_json
  end

  def self.all
    REDIS.hvals(PRODUCTS_KEY).map { |p| from_json(p) }.compact
  end

  def self.find(id)
    prod_json = REDIS.hget(PRODUCTS_KEY, id)
    from_json(prod_json)
  end

  def self.create(name)
    return nil unless valid_name?(name)
    id = REDIS.incr(PRODUCT_ID_KEY)
    product = new(id: id, name: name)
    REDIS.hset(PRODUCTS_KEY, id, product.to_json)
    product
  end

  def self.update(id, name)
    return nil unless valid_name?(name)
    product = find(id)
    return nil unless product
    updated = new(id: product.id, name: name)
    REDIS.hset(PRODUCTS_KEY, id, updated.to_json)
    updated
  end

  private

  def self.valid_name?(name)
    name.is_a?(String) && !name.strip.empty?
  end

  def self.from_json(json)
    data = JSON.parse(json) rescue nil
    return nil unless data.is_a?(Hash) && data['id'] && data['name']
    new(id: data['id'], name: data['name'])
  end
end
