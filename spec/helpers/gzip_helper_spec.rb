require 'rspec'
require 'zlib'
require_relative '../../app/helpers/gzip_helper'

RSpec.describe GzipHelper do
  describe '.compress' do
    it 'compresses a string and returns it in gzip format' do
      text = 'hello world'
      result = GzipHelper.compress(text)
      expect(result).to be_an(Array)
      expect(result.size).to eq(1)
      decompressed = Zlib::GzipReader.new(StringIO.new(result.first)).read
      expect(decompressed).to eq(text)
    end

    it 'compresses an array of strings and returns them in gzip format' do
      texts = ['one', 'two']
      result = GzipHelper.compress(texts)
      expect(result.size).to eq(2)
      expect(Zlib::GzipReader.new(StringIO.new(result[0])).read).to eq('one')
      expect(Zlib::GzipReader.new(StringIO.new(result[1])).read).to eq('two')
    end

    it 'returns an empty array if the input is empty' do
      result = GzipHelper.compress([])
      expect(result).to eq([])
    end
  end
end
