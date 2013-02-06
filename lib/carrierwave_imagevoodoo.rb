Bundler.require

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
          cols = (scale * cols).round
          rows = (scale * rows).round
          image.resize cols, rows do |img|
            yield(img) if block_given?
            img.save current_path
          end
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
            file.save( self.current_path )
          end
        end
      end
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

    def manipulate!
      yield ::ImageVoodoo.with_bytes file.read
    end
  end
end
