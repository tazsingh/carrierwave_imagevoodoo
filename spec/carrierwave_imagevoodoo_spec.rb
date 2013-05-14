require 'spec_helper'

describe CarrierWave::ImageVoodoo do
  let :klass do
    Class.new do
      include CarrierWave::ImageVoodoo
    end
  end

  let :instance do
    klass.new
  end

  before do
    FileUtils.cp(file_path('cat.jpg'), file_path('cat_copy.jpg'))
    instance.stub(:file).and_return(File.new(file_path('cat_copy.jpg')))
    instance.stub(:current_path).and_return(file_path('cat_copy.jpg'))
    instance.stub(:cached?).and_return true
  end

  after do
    FileUtils.rm(file_path('cat_copy.jpg'))
  end

  describe '#resize_to_fit' do
    it "should resize the image to fit within the given dimensions" do
      instance.resize_to_fit(200, 200)
      instance.should have_dimensions(127, 200)
    end

    it "should not resize an image whose largest side matchesthe given dimensions" do
      instance.resize_to_fit(1000, 1000)
      instance.should have_dimensions(635, 1000)
    end

    it "should scale the image up if smaller than given dimensions" do
      instance.resize_to_fit(2000, 2000)
      instance.should have_dimensions(1270, 2000)
    end
  end

  describe '#resize_to_fill' do
    it "should resize the image to exactly the given dimensions" do
      instance.resize_to_fill(200, 200)
      instance.should have_dimensions(200, 200)
    end

    it "should scale the image up if smaller than given dimensions" do
      instance.resize_to_fill(1000, 1000)
      instance.should have_dimensions(1000, 1000)
    end
  end

  describe '#resize_to_limit' do
    it "resizes the image to fit when height is constraining dimension" do
      instance.resize_to_limit(700, 200)
      instance.should have_dimensions(127, 200)
    end
    
    it "resizes image to fit when width is constraining dimension" do
      instance.resize_to_limit(127, 2000)
      instance.should have_dimensions(127, 200)
    end

    it "does not scale up the image if smaller than given dimensions" do
      instance.resize_to_limit(2000, 2000)
      instance.should have_dimensions(635, 1000)
    end
  end
end
