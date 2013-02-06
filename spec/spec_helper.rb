Bundler.require :development
require 'carrierwave_imagevoodoo'

def file_path( *paths )
  File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', *paths))
end

class HaveDimensions
  def initialize(width, height)
    @width, @height = width, height
  end

  def matches?(actual)
    @actual = actual
    # Satisfy expectation here. Return false or raise an error if it's not met.
    image = ::ImageVoodoo.with_bytes File.new(@actual.current_path).read
    @actual_width = image.width
    @actual_height = image.height
    @actual_width == @width && @actual_height == @height
  end

  def failure_message
    "expected #{@actual.current_path.inspect} to have an exact size of #{@width} by #{@height}, but it was #{@actual_width} by #{@actual_height}."
  end

  def negative_failure_message
    "expected #{@actual.current_path.inspect} not to have an exact size of #{@width} by #{@height}, but it did."
  end

  def description
    "have an exact size of #{@width} by #{@height}"
  end
end

def have_dimensions(width, height)
  HaveDimensions.new(width, height)
end
