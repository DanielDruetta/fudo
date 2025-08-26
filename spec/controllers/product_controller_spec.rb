require 'rspec'
require 'json'
require_relative '../../app/controllers/product_controller'

RSpec.describe ProductController do
  let(:headers) { { 'HTTP_AUTHORIZATION' => auth_header } }
  let(:body) { double('Body', read: body_content) }
  let(:req) { double('Request', body: body, get_header: headers['HTTP_AUTHORIZATION']) }
  let(:controller) { ProductController.new(req) }

  describe '#index' do
    let(:body_content) { '' }
    let(:auth_header) { 'Bearer valid-token' }
    let(:products) { [double(to_h: { id: 1, name: 'A' }), double(to_h: { id: 2, name: 'B' })] }
    before { stub_const('ProductService', double(all: products)) }

    it 'returns 200 and products list when authorized' do
      status, headers, body = controller.index
      expect(status).to eq(200)
      expect(headers['content-type']).to eq('application/json')
      expect(JSON.parse(body.first)).to be_an(Array)
      expect(JSON.parse(body.first).size).to eq(2)
    end

    context 'when unauthorized' do
      let(:body_content) { '' }
      let(:auth_header) { 'Bearer invalid-token' }
      it 'returns 401' do
        status, headers, body = controller.index
        expect(status).to eq(401)
        expect(JSON.parse(body.first)['error']).to eq('Unauthorized')
      end
    end
  end

  describe '#create' do
    let(:auth_header) { 'Bearer valid-token' }
    before do
      stub_const('ProductService', double(create_async: 'jid123'))
      allow(Product).to receive(:valid_name?).and_call_original
    end

    context 'with valid params' do
      let(:body_content) { { name: 'New Product' }.to_json }
      it 'returns 202 and job id' do
        allow(Product).to receive(:valid_name?).with('New Product').and_return(true)
        status, headers, body = controller.create
        expect(status).to eq(202)
        expect(JSON.parse(body.first)['job_id']).to eq('jid123')
      end
    end

    context 'with missing name' do
      let(:body_content) { { name: '' }.to_json }
      it 'returns 400' do
        allow(Product).to receive(:valid_name?).with('').and_return(false)
        status, headers, body = controller.create
        expect(status).to eq(400)
        expect(JSON.parse(body.first)['error']).to eq('Name required')
      end
    end

    context 'with malformed JSON' do
      let(:body_content) { 'not a json' }
      it 'returns 400' do
        status, headers, body = controller.create
        expect(status).to eq(400)
        expect(JSON.parse(body.first)['error']).to eq('Invalid JSON')
      end
    end

    context 'when unauthorized' do
      let(:auth_header) { 'Bearer invalid-token' }
      let(:body_content) { { name: 'New Product' }.to_json }
      it 'returns 401' do
        status, headers, body = controller.create
        expect(status).to eq(401)
        expect(JSON.parse(body.first)['error']).to eq('Unauthorized')
      end
    end
  end

  describe '#update' do
    let(:auth_header) { 'Bearer valid-token' }
    let(:id) { 1 }
    let(:prod) { double(to_h: { id: 1, name: 'Updated' }) }
    before do
      stub_const('ProductService', double(update: prod))
      allow(Product).to receive(:valid_name?).and_call_original
    end

    context 'with valid params and product exists' do
      let(:body_content) { { name: 'Updated' }.to_json }
      it 'returns 200 and updated product' do
        allow(Product).to receive(:valid_name?).with('Updated').and_return(true)
        status, headers, body = controller.update(id)
        expect(status).to eq(200)
        expect(JSON.parse(body.first)['name']).to eq('Updated')
      end
    end

    context 'with missing name' do
      let(:body_content) { { name: '' }.to_json }
      it 'returns 400' do
        allow(Product).to receive(:valid_name?).with('').and_return(false)
        status, headers, body = controller.update(id)
        expect(status).to eq(400)
        expect(JSON.parse(body.first)['error']).to eq('Name required')
      end
    end

    context 'with malformed JSON' do
      let(:body_content) { 'not a json' }
      it 'returns 400' do
        status, headers, body = controller.update(id)
        expect(status).to eq(400)
        expect(JSON.parse(body.first)['error']).to eq('Invalid JSON')
      end
    end

    context 'when product not found' do
      before { stub_const('ProductService', double(update: nil)) }
      let(:body_content) { { name: 'Updated' }.to_json }
      it 'returns 404' do
        allow(Product).to receive(:valid_name?).with('Updated').and_return(true)
        status, headers, body = controller.update(id)
        expect(status).to eq(404)
        expect(JSON.parse(body.first)['error']).to eq('Product not found')
      end
    end

    context 'when unauthorized' do
      let(:auth_header) { 'Bearer invalid-token' }
      let(:body_content) { { name: 'Updated' }.to_json }
      it 'returns 401' do
        status, headers, body = controller.update(id)
        expect(status).to eq(401)
        expect(JSON.parse(body.first)['error']).to eq('Unauthorized')
      end
    end
  end
end
