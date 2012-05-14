# CarrierWave ImageVoodoo

CarrierWave support for ImageVoodoo

## Installation

Add this line to your application's Gemfile:

    gem 'image_voodoo'
    gem 'carrierwave_imagevoodoo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install image_voodoo carrierwave_imagevoodoo

## Usage

Simply include `CarrierWave::ImageVoodoo` in your CarrierWave Uploader:

    class MyUploader < CarrierWave::Uploader::Base
      include CarrierWave::ImageVoodoo

      # do some processing...
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
