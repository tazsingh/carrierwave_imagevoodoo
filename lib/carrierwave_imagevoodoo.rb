require "carrierwave_imagevoodoo/version"
require "active_support/concern"
require "image_voodoo"

module CarrierWave
  module ImageVoodoo
    extend ActiveSupport::Concern

    module ClassMethods
      def convert format
        process :convert => format
      end

      #def resize_to_limit width, height
      #  process :resize_to_limit => [width, height]
      #end

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
        image.save "#{current_path.chomp(File.extname(f))}.#{format}"
      end
    end

    #def resize_to_limit width, height
    #end

    def resize_to_fit width, height
      manipulate! do |image|
        cols = image.width
        rows = image.height

        if width != cols or height != rows
          scale = [width/cols.to_f, height/rows.to_f].min
          cols = (scale * (cols + 0.5)).round
          rows = (scale * (rows + 0.5)).round
          image.resize cols, rows do |img|
            yield(img) if block_given?
            img.save current_path
          end
        end
      end
    end

    def resize_to_fill width, height
      manipulate! do |image|
        cols = image.width
        rows = image.height

        if width != cols or height != rows
          scale = [width/cols.to_f, height/rows.to_f].max
          cols = (scale * (cols + 0.5)).round
          rows = (scale * (rows + 0.5)).round
          image.resize cols, rows do |img|
            yield(img) if block_given?
            img.save current_path
          end
        end
      end
    end

    #def resize_and_pad width, height, background = :transparent
    #end

    def manipulate!
      yield ::ImageVoodoo.with_bytes file.read
    end
  end
end