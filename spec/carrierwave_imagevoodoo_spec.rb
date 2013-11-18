require "spec_helper"

describe CarrierWave::ImageVoodoo do
  let :klass do
    Class.new do
      include CarrierWave::ImageVoodoo
    end
  end

  subject do
    klass.new
  end

  before do
    FileUtils.cp(file_path("cat.jpg"), file_path("cat_copy.jpg"))
    subject.stub(:file).and_return(File.new(file_path("cat_copy.jpg")))
    subject.stub(:current_path).and_return(file_path("cat_copy.jpg"))
    subject.stub(:cached?).and_return true
  end

  after do
    FileUtils.rm(file_path("cat_copy.jpg"))
  end

  describe "#resize_to_fit" do
    context "image is larger than dimensions" do
      before { subject.resize_to_fit(200, 200) }

      it { should have_dimensions(127, 200) }
    end

    context "image's largest side matches dimensions" do
      before { subject.resize_to_fit(1000, 1000) }

      it { should have_dimensions(635, 1000) }
    end

    context "image is upscaled if smaller than dimensions" do
      before { subject.resize_to_fit(2000, 2000) }

      it { should have_dimensions(1270, 2000) }
    end
  end

  describe '#resize_to_fill' do
    context "image is exactly the same dimensions" do
      before { subject.resize_to_fill(200, 200) }

      it { should have_dimensions(200, 200) }
    end

    context "image is scaled up if smaller than dimensions" do
      before { subject.resize_to_fill(1000, 1000) }

      it { should have_dimensions(1000, 1000) }
    end
  end

  describe '#resize_to_limit' do
    context "image fits within height constraints" do
      before { subject.resize_to_limit(700, 200) }

      it { should have_dimensions(127, 200) }
    end

    context "image fits within width constraints" do
      before { subject.resize_to_limit(127, 2000) }

      it { should have_dimensions(127, 200) }
    end

    context "image does not scale up if smaller than dimensions" do
      before { subject.resize_to_limit(2000, 2000) }

      it { should have_dimensions(635, 1000) }
    end
  end

  describe "#dimensions" do
    its(:dimensions) { should == [635, 1000] }

    context "after processing" do
      before { subject.resize_to_limit(127, 2000) }

      its(:dimensions) { should == [127, 200] }
    end
  end
end
