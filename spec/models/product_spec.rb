require 'rspec'
require 'json'
require_relative '../../app/models/product'

RSpec.describe Product do
  let(:redis) { double('Redis') }
  before { stub_const('REDIS', redis) }

  describe '.valid_name?' do
    it 'returns true for a valid name' do
      expect(Product.send(:valid_name?, 'Pizza')).to be true
    end
    it 'returns false for empty string' do
      expect(Product.send(:valid_name?, '')).to be false
    end
    it 'returns false for nil' do
      expect(Product.send(:valid_name?, nil)).to be false
    end
    it 'returns false for non-string' do
      expect(Product.send(:valid_name?, 123)).to be false
    end
  end

  describe '.create' do
    it 'creates a product with valid name' do
      allow(redis).to receive(:incr).and_return(1)
      allow(redis).to receive(:hset)
      product = Product.create('Burger')
      expect(product).to be_a(Product)
      expect(product.name).to eq('Burger')
      expect(product.id).to eq(1)
    end
    it 'returns nil for invalid name' do
      expect(Product.create('')).to be_nil
    end
  end

  describe '.update' do
    it 'updates product name if product exists and name is valid' do
      product = Product.new(id: 1, name: 'Old')
      allow(Product).to receive(:find).with(1).and_return(product)
      allow(redis).to receive(:hset)
      updated = Product.update(1, 'New')
      expect(updated).to be_a(Product)
      expect(updated.name).to eq('New')
      expect(updated.id).to eq(1)
    end
    it 'returns nil if product does not exist' do
      allow(Product).to receive(:find).with(2).and_return(nil)
      expect(Product.update(2, 'New')).to be_nil
    end
    it 'returns nil for invalid name' do
      expect(Product.update(1, '')).to be_nil
    end
  end

  describe '.find' do
    it 'returns product if found in redis' do
      prod_json = { id: 1, name: 'Soda' }.to_json
      allow(redis).to receive(:hget).with('products', 1).and_return(prod_json)
      product = Product.find(1)
      expect(product).to be_a(Product)
      expect(product.name).to eq('Soda')
    end
    it 'returns nil if not found' do
      allow(redis).to receive(:hget).with('products', 2).and_return(nil)
      expect(Product.find(2)).to be_nil
    end
  end

  describe '.all' do
    it 'returns all products from redis' do
      prod_jsons = [ { id: 1, name: 'A' }.to_json, { id: 2, name: 'B' }.to_json ]
      allow(redis).to receive(:hvals).with('products').and_return(prod_jsons)
      products = Product.all
      expect(products.size).to eq(2)
      expect(products.map(&:name)).to contain_exactly('A', 'B')
    end
    it 'returns empty array if no products' do
      allow(redis).to receive(:hvals).with('products').and_return([])
      expect(Product.all).to eq([])
    end
  end

  describe '#to_h and #to_json' do
    let(:product) { Product.new(id: 5, name: 'Juice') }
    it 'returns hash representation' do
      expect(product.to_h).to eq({ id: 5, name: 'Juice' })
    end
    it 'returns json representation' do
      expect(JSON.parse(product.to_json)).to eq({ 'id' => 5, 'name' => 'Juice' })
    end
  end

  describe '.from_json' do
    it 'returns product from valid json' do
      json = { id: 10, name: 'Water' }.to_json
      product = Product.send(:from_json, json)
      expect(product).to be_a(Product)
      expect(product.id).to eq(10)
      expect(product.name).to eq('Water')
    end
    it 'returns nil from invalid json' do
      expect(Product.send(:from_json, 'not json')).to be_nil
      expect(Product.send(:from_json, '{}')).to be_nil
    end
  end
end
