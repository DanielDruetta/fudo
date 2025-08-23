module GzipHelper
  def self.compress(body)
    require 'stringio'
    require 'zlib'
    Array(body).map do |b|
      io = StringIO.new
      gz = Zlib::GzipWriter.new(io)
      gz.write(b)
      gz.close
      io.string
    end
  end
end
