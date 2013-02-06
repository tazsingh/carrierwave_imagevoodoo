require "benchmark"
require "carrierwave"

class CatUploader < CarrierWave::Uploader::Base
  storage :file

  100.times do |i|
    version "size#{i}" do
      process resize_to_fit: [200, 200]
    end
  end
end

cat_file = File.new("images/cat.jpg")

case RUBY_PLATFORM
when "java"
  require "../lib/carrierwave_imagevoodoo"
  CatUploader.send :include, CarrierWave::ImageVoodoo
else
  CatUploader.send :include, CarrierWave::MiniMagick
end

instance = CatUploader.new

if File.directory? "uploads"
  FileUtils.rm_r "uploads"
end

puts "STARTED"
3.times do
  puts Benchmark.measure {
    instance.store! cat_file
  }

  FileUtils.rm_r "uploads"
end
puts "ENDED"
