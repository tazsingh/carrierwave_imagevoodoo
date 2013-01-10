require File.dirname(__FILE__) + '/spec_helper'
require 'carrierwave_imagevoodoo'
require 'carrierwave'
require 'carrierwave/uploader'
require 'image_voodoo'

# The cat in the examples was taken from The Flickr Commons
# http://www.flickr.com/photos/george_eastman_house/2720791942/
# The picture has no known copyright restrictions

class CatUploader < CarrierWave::Uploader::Base
  include CarrierWave::ImageVoodoo

  def initialize(model=nil, mounted_as=nil)
    super(model, mounted_as)
    self.store_dir = "#{root}/tmp/cats"
    self.cache_dir = "#{root}/tmp/cache"
  end

  version :thumb do
    process :resize_to_fit => [200, 200]
  end
end

describe CarrierWave::ImageVoodoo do

  before :all do
    @root_dir = begin
      dir = File.dirname(__FILE__)
      while !Dir.entries(dir).include?("Gemfile")
        dir = File.expand_path("..", Dir.pwd)
      end
      dir
    end
    CarrierWave.configure do |config|
      config.storage = :file
      config.root = @root_dir
      config.enable_processing = true
    end

    @cats_dir = File.join(@root_dir, "tmp/cats")

    FileUtils.mkdir_p(@cats_dir)

    @cat_uploader = CatUploader.new
    File.open(File.dirname(__FILE__) + '/cat.jpg') do |cat|
      @cat_uploader.store!(cat)
    end
  end

  # Sanity check
  it "should be able to access the stored file" do
    cat = @cat_uploader.store_path
    File.exist?(cat).should be_true # File.should be_exist just sounds wrong
  end

  it "should create a version of the cat image fitting within 200px" do
    cat = @cat_uploader.thumb.store_path
    ImageVoodoo.with_image(cat) do |img|
      img.width.should < 200
      img.height.should eq(200)
    end
  end

  after :all do
    FileUtils.rm_rf(File.join(@root_dir, "tmp", "cats"))
    FileUtils.rm_rf(File.join(@root_dir, "tmp", "cache"))
  end
end