require 'rmagick'

# Paginate text and generates a series of _square images_ from said text.
module TextRasterizer
    # This class represents one image (frame) of text.
    class TextFrame
        # @param text [String] main body text the frame holds
        # @param by_line [String] one line of text, placed at bottom of frame
        # @param image_width [FixNum] how wide/tall the image itself is, in pixels
        # @param margin [FixNum] text margin from top and left, in pixels
        # @param font_size [FixNum] size of text in frame, in points
        # @param font_family [String] font family to use
        def initialize(text, by_line, image_width, margin, font_family, font_size)
            @text = text
            @image_width = image_width
            @margin = margin
            @text_width = image_width - (2 * margin) # How wide the text rectangle will be 
            puts @text_width
            @pointsize = font_size
            @by_line = by_line
            @font_family = font_family
            @font_size = font_size
        end

        # Generate the frame and save it at +path+ specified.
        # @param path [String] path at which to save (and *overwrite*) the generated frame. 
        # @return [nil]
        def generate_file(path)
            image = Magick::Image.new @image_width, @image_width
            text = Magick::Draw.new
            text.font_family = @font_family
            text.pointsize = @pointsize
            # body
            text.annotate(image, @text_width, 0.8 * @text_width, @margin, @margin, @text) { self.gravity = Magick::NorthWestGravity }
            # byline
            text.annotate(image, 0, 0, @margin, 0.4 * @text_width, @by_line) { self.gravity = Magick::WestGravity }            
            image.write(path)
            nil
        end
    end

    # A series of one or more (i.e. if the text is too long for 1 frame) frames of text
    class TextSeries
        # @param body [String] the whole body text, without breaks or newlines
        # @param middle_byline [String] the byline between images
        # @param end_byline [String] the byline at the very end of the series
        # @param image_width [FixNum] the width of the image, in pixels
        # @param margin [FixNum] text margin from left, in pixels
        def initialize(body, middle_byline, end_byline, image_width, margin, font_family, font_size)
            @body = body
            @middle_byline = middle_byline
            @end_byline = end_byline
            @image_width = image_width
            @margin = margin
            @text_width = image_width - (2 * margin)
            @font_family = font_family
            @font_size = font_size
        end

        # Returns true if some text can fit within an image's width.
        # @param text [String] the text to check
        # @param width [FixNum] the width of the image, in pixels
        # @return [Symbol, false] +:width+ or +:height+ depending on which needs to be split, or +false+ if it does not.
        def text_needs_splitting?(text, width, margin, pointsize)
            tmp_image = Magick::Image.new(width, 500)
            drawing = Magick::Draw.new
            drawing.gravity = Magick::WestGravity
            drawing.pointsize = pointsize
            drawing.fill = "#ffffff"
            drawing.font_family = @font_family
            drawing.annotate(tmp_image, (width - margin), (width - margin), margin, margin, text)
            metrics = drawing.get_multiline_type_metrics(tmp_image, text)
            if metrics.width >= width
                return :width
            elsif metrics.height > (0.7 * width)
                return :height
            else
                return false
            end           
        end

        # Splits the current text text into image-fitting pages, and makes #TextFrame objects ready to generate.
        # @return [Array<TextFrame>] An array of TextFrames containing strings grouped by page with `\n`s added.
        def paginate
            separator = ' '
            current_chunk = ''
            chunks = []
            if text_needs_splitting?(@body, @text_width, @margin, @font_size) and @body.include? separator
                i = 0
                @body.split(separator).each do |word|
                    if i == 0
                        tmp_line = current_chunk + word
                    else
                        tmp_line = current_chunk + separator + word
                    end
                    needs_splitting_along = text_needs_splitting?(tmp_line, @text_width, @margin, @font_size)
                    if not needs_splitting_along
                        unless i == 0
                            current_chunk += separator
                        end
                        current_chunk += word
                    elsif needs_splitting_along == :width
                        unless i == 0
                            current_chunk +=  '\n'
                        end
                        current_chunk += word
                    elsif needs_splitting_along == :height
                        chunks << TextFrame.new(current_chunk, @middle_byline, @image_width, @margin, @font_family, @font_size)
                        current_chunk = word
                    end
                    i += 1
                end
            end
            chunks << TextFrame.new(current_chunk, @end_byline, @image_width, @margin, @font_family, @font_size)
            return chunks
        end
    end
end
