require "carrierwave"
require "image_voodoo"
require "active_support/concern"

module CarrierWave
  module ImageVoodoo
    extend ActiveSupport::Concern

    module ClassMethods
      def convert format
        process :convert => format
      end

      def resize_to_limit width, height
        process :resize_to_limit => [width, height]
      end

      def resize_to_fit width, height
        process :resize_to_fit => [width, height]
      end

      def resize_to_fill width, height
        process :resize_to_fill => [width, height]
      end

      #def resize_and_pad width, height, background = :transparent
      #  process :resize_and_pad => [width, height, background]
      #end
    end

    def convert format
      manipulate! do |image|
        yield(image) if block_given?

        image.save_impl format, Java::JavaIo::File.new(
          "#{current_path.chomp(File.extname(current_path))}.#{format}"
        )
      end
    end

    def resize_to_limit width, height
      manipulate! do |image|
        if (width < image.width) || (height < image.height)
          resize_to_fit!(image, width, height)
        end
      end
    end

    def resize_to_fit width, height
      manipulate! do |image|
        if (width != image.width) || (height != image.height)
          resize_to_fit!(image, width, height)
        end
      end
    end

    def resize_to_fill(new_width, new_height)
      manipulate! do |image|
        cols = image.width
        rows = image.height
        width, height = extract_dimensions_for_crop(image.width, image.height, new_width, new_height)
        x_offset, y_offset = extract_placement_for_crop(width, height, new_width, new_height)

        # check if if new dimensions are too small for the new image
        if width < new_width
          width = new_width
          height = (new_width.to_f*(image.height.to_f/image.width.to_f)).round
        elsif height < new_height
          height = new_height
          width = (new_height.to_f*(image.width.to_f/image.height.to_f)).round
        end

        image.resize( width, height ) do |i2|

          # check to make sure offset is not negative
          if x_offset < 0
            x_offset = 0
          end
          if y_offset < 0
            y_offset = 0
          end

          i2.with_crop( x_offset, y_offset, new_width + x_offset, new_height + y_offset) do |file|
            file.save_impl format, Java::JavaIo::File.new(current_path)
          end
        end
      end
    end

    def dimensions
      image = image_voodoo_image

      [image_voodoo_image.width, image_voodoo_image.height]
    end

    private

    def extract_dimensions(width, height, new_width, new_height, type = :resize)
      aspect_ratio = width.to_f / height.to_f
      new_aspect_ratio = new_width / new_height

      if (new_aspect_ratio > aspect_ratio) ^ ( type == :crop ) # Image is too wide, the caret is the XOR operator
        new_width, new_height = [ (new_height * aspect_ratio), new_height]
      else #Image is too narrow
        new_width, new_height = [ new_width, (new_width / aspect_ratio)]
      end

      [new_width, new_height].collect! { |v| v.round }
    end

    def extract_dimensions_for_crop(width, height, new_width, new_height)
      extract_dimensions(width, height, new_width, new_height, :crop)
    end

    def extract_placement_for_crop(width, height, new_width, new_height)
      x_offset = (width / 2.0) - (new_width / 2.0)
      y_offset = (height / 2.0) - (new_height / 2.0)
      [x_offset, y_offset].collect! { |v| v.round }
    end

    #def resize_and_pad width, height, background = :transparent
    #end

    def image_voodoo_image
      ::ImageVoodoo.with_bytes File.read(current_path)
    end

    def format
      format = if respond_to? :filename
        File.extname filename
      else
        File.extname current_path
      end

      if format.size > 0
        format[1..-1]
      end
    end

    def manipulate!
      yield image_voodoo_image
    end

    def resize_to_fit! image, width, height
      w_ratio = width / image.width.to_f
      h_ratio = height / image.height.to_f
      ratio = [w_ratio, h_ratio].min

      image.scale(ratio) do |img|
        img.save_impl format, Java::JavaIo::File.new(current_path)
      end
    end
  end
end
