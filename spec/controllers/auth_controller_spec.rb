require 'rspec'
require 'json'
require 'bcrypt'
require_relative '../../app/controllers/auth_controller'

RSpec.describe AuthController do
  let(:redis) { double('Redis') }
  let(:req) { double('Request', body: double('Body', read: body_content)) }
  let(:controller) { AuthController.new(req) }

  before do
    stub_const('REDIS', redis)
  end

  describe '#login' do
    context 'with valid credentials' do
      let(:body_content) { { user: 'admin', password: 'secret' }.to_json }
      it 'returns 200 and a token' do
        pass_hash = BCrypt::Password.create('secret')
        allow(redis).to receive(:get).with('users:admin').and_return(pass_hash)
        allow(redis).to receive(:setex)
        status, headers, body = controller.login
        expect(status).to eq(200)
        expect(headers['content-type']).to eq('application/json')
        token = JSON.parse(body.first)['token']
        expect(token).to be_a(String)
        expect(token.size).to be > 10
      end
    end

    context 'with invalid credentials' do
      let(:body_content) { { user: 'admin', password: 'wrong' }.to_json }
      it 'returns 401 and error message' do
        pass_hash = BCrypt::Password.create('secret')
        allow(redis).to receive(:get).with('users:admin').and_return(pass_hash)
        status, headers, body = controller.login
        expect(status).to eq(401)
        expect(headers['content-type']).to eq('application/json')
        expect(JSON.parse(body.first)['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid parameters' do
      let(:body_content) { { user: 'admin' }.to_json }
      it 'returns 400 and error message' do
        status, headers, body = controller.login
        expect(status).to eq(400)
        expect(headers['content-type']).to eq('application/json')
        expect(JSON.parse(body.first)['error']).to eq('Invalid parameters')
      end
    end

    context 'with malformed JSON' do
      let(:body_content) { 'not a json' }
      it 'returns 400 and error message' do
        status, headers, body = controller.login
        expect(status).to eq(400)
        expect(headers['content-type']).to eq('application/json')
        expect(JSON.parse(body.first)['error']).to eq('Invalid JSON')
      end
    end
  end
end
