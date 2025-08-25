require 'rspec'
require_relative '../../app/services/product_service'

RSpec.describe ProductService do
  describe '.all' do
    it 'returns all products' do
      products = [double('Product'), double('Product')]
      allow(Product).to receive(:all).and_return(products)
      expect(ProductService.all).to eq(products)
    end
  end

  describe '.create_async' do
    it 'calls ProductWorker.perform_async with name' do
      expect(ProductWorker).to receive(:perform_async).with('Pizza').and_return('jobid123')
      result = ProductService.create_async('Pizza')
      expect(result).to eq('jobid123')
    end
  end

  describe '.update' do
    it 'calls Product.update with id and name' do
      updated_product = double('Product')
      expect(Product).to receive(:update).with(1, 'Burger').and_return(updated_product)
      result = ProductService.update(1, 'Burger')
      expect(result).to eq(updated_product)
    end
  end
end
