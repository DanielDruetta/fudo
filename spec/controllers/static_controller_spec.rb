require 'rspec'
require 'json'
require_relative '../../app/controllers/static_controller'

RSpec.describe StaticController do
  let(:req) { double('Request') }
  let(:controller) { StaticController.new(req) }

  describe '#openapi' do
    context 'when file exists' do
      before do
        allow(File).to receive(:expand_path).and_return('/tmp/openapi.yaml')
        allow(File).to receive(:exist?).with('/tmp/openapi.yaml').and_return(true)
        allow(File).to receive(:read).with('/tmp/openapi.yaml').and_return('openapi content')
      end
      it 'returns 200 and file content' do
        status, headers, body = controller.openapi
        expect(status).to eq(200)
        expect(headers['content-type']).to eq('application/yaml')
        expect(headers['cache-control']).to eq('no-store, no-cache, must-revalidate')
        expect(body.first).to eq('openapi content')
      end
    end

    context 'when file does not exist' do
      before do
        allow(File).to receive(:expand_path).and_return('/tmp/openapi.yaml')
        allow(File).to receive(:exist?).with('/tmp/openapi.yaml').and_return(false)
      end
      it 'returns 404 and error message' do
        status, headers, body = controller.openapi
        expect(status).to eq(404)
        expect(headers['content-type']).to eq('application/json')
        expect(JSON.parse(body.first)['error']).to eq('Not found')
      end
    end
  end

  describe '#authors' do
    context 'when file exists' do
      before do
        allow(File).to receive(:expand_path).and_return('/tmp/AUTHORS')
        allow(File).to receive(:exist?).with('/tmp/AUTHORS').and_return(true)
        allow(File).to receive(:read).with('/tmp/AUTHORS').and_return('author list')
      end
      it 'returns 200 and file content' do
        status, headers, body = controller.authors
        expect(status).to eq(200)
        expect(headers['content-type']).to eq('text/plain')
        expect(headers['cache-control']).to eq('public, max-age=86400')
        expect(body.first).to eq('author list')
      end
    end

    context 'when file does not exist' do
      before do
        allow(File).to receive(:expand_path).and_return('/tmp/AUTHORS')
        allow(File).to receive(:exist?).with('/tmp/AUTHORS').and_return(false)
      end
      it 'returns 404 and error message' do
        status, headers, body = controller.authors
        expect(status).to eq(404)
        expect(headers['content-type']).to eq('application/json')
        expect(JSON.parse(body.first)['error']).to eq('Not found')
      end
    end
  end
end
