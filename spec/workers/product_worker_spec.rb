require 'rspec'
require_relative '../../app/workers/product_worker'

RSpec.describe ProductWorker do
  describe '#perform' do
    it 'calls Product.create with the given name' do
      worker = ProductWorker.new
      expect(Product).to receive(:create).with('Pizza')
      worker.perform('Pizza')
    end
  end
end
