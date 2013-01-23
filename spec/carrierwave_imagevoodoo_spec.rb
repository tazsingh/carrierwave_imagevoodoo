require 'spec_helper'

describe CarrierWave::ImageVoodoo do
  before do
    @klass = Class.new do
      include CarrierWave::ImageVoodoo
    end
    @instance = @klass.new
    FileUtils.cp(file_path('cat.jpg'), file_path('cat_copy.jpg'))
    @instance.stub(:file).and_return(File.new(file_path('cat_copy.jpg')))
    @instance.stub(:current_path).and_return(file_path('cat_copy.jpg'))
    @instance.stub(:cached?).and_return true
  end

  after do
    FileUtils.rm(file_path('cat_copy.jpg'))
  end

  describe '#resize_to_fit' do
    it "should resize the image to fit within the given dimensions" do
      @instance.resize_to_fit(200, 200)
      @instance.should have_dimensions(127, 200)
    end

    it "should not resize an image whose largest side matchesthe given dimensions" do
      @instance.resize_to_fit(1000, 1000)
      @instance.should have_dimensions(635, 1000)
    end

    it "should scale the image up if smaller than given dimensions" do
      @instance.resize_to_fit(2000, 2000)
      @instance.should have_dimensions(1270, 2000)
    end
  end

  describe '#resize_to_fill' do
    it "should resize the image to exactly the given dimensions" do
      @instance.resize_to_fill(200, 200)
      @instance.should have_dimensions(200, 200)
    end

    it "should scale the image up if smaller than given dimensions" do
      @instance.resize_to_fill(1000, 1000)
      @instance.should have_dimensions(1000, 1000)
    end
  end
end
