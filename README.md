# Text Rasterizer

This small Ruby module rasterises text into one or more images of text, suitable for upload to social media.

## Dependencies
* rmagick
* ...which depends on ImageMagick 6.4.9 or later (if you're on OSX and are having issues with homebrew, see [here](https://stackoverflow.com/a/43035892).

## Usage
```ruby
# assuming you have instagram-pages.rb in the directory
require 'textrast'

text = TextRasterizer::TextSeries.new "Body text!", "(would be used for bylines in the middle)", "- Final byline", 500, 50, "Times New Roman"
photos = text.paginate
photos.each_with_index { |photo, i| photo.generate_file "photo_#{i}.png" }
```

For more info, please take a look at the [docs](https://kaine119.github.io/instagram-pages)
