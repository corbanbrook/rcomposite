module RComposite
  # Fill layer types

  SolidColor = 0
  Gradient = 1
  Pattern = 2
  
  class FillLayer < Layer
    attr_accessor :image
    attr_reader :offset_x, :offset_y

    def initialize(type, *args, &block)
      case type
        when SolidColor
          color = args[0]

          fill = Magick::GradientFill.new(0, 0, 0, 0, color, color)
          
        when Gradient
          x1 = args[0]
          y1 = args[1]
          x2 = args[2]
          y2 = args[3]
          color1 = args[4]
          color2 = args[5]

          fill = Magick::GradientFill.new(x1, y1, x2, y2, color1, color2)
        
        when Pattern
          image = args[0]

          fill = Magick::TextureFill.new(image)
      end

      @image = Magick::Image.new($RCompositeCanvasWidth, $RCompositeCanvasHeight, fill)

      @image.matte = true
      @mode = Normal
      @offset_x = 0
      @offset_y = 0
      @opacity_percent = 100
    end
  end
end
