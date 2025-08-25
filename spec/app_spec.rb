require 'rspec'
require 'rack'
require_relative '../app/app'

RSpec.describe App do
  let(:app) { App.new }
  let(:env) do
    {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/test',
      'HTTP_ACCEPT_ENCODING' => accept_encoding
    }
  end
  let(:accept_encoding) { nil }

  before do
    stub_const('Routes', double(call: [200, { 'content-type' => 'application/json' }, ['{"ok":true}']]))
    allow_any_instance_of(Logger).to receive(:info)
    allow_any_instance_of(Logger).to receive(:error)
  end

  it 'returns a valid Rack response for a normal request' do
    status, headers, body = app.call(env)
    expect(status).to eq(200)
    expect(headers['content-type']).to eq('application/json')
    expect(body.join).to include('ok')
  end

  it 'returns gzip response when Accept-Encoding includes gzip' do
    stub_const('GzipHelper', double(compress: ['compressed']))
    env['HTTP_ACCEPT_ENCODING'] = 'gzip, deflate'
    status, headers, body = app.call(env)
    expect(headers['content-encoding']).to eq('gzip')
    expect(body).to eq(['compressed'])
  end

  it 'returns 500 and error message if Routes.call raises error' do
    allow(Routes).to receive(:call).and_raise('fail')
    status, headers, body = app.call(env)
    expect(status).to eq(500)
    expect(headers['content-type']).to eq('application/json')
    expect(body.join).to include('Internal Server Error')
  end

  it 'sets default status to 200 if status is nil' do
    stub_const('Routes', double(call: [nil, { 'content-type' => 'application/json' }, ['{"ok":true}']]))
    status, headers, body = app.call(env)
    expect(status).to eq(200)
  end
end
