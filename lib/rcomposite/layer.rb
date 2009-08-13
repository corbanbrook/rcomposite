module RComposite
  # Layer mode constants 
  #   some of photoshops layer modes are directly equvilent to RMagick 
  #   some are not, and some arent supported at all.

  Normal = Magick::OverCompositeOp # PS equivilent
  Dissolve = Magick::DissolveCompositeOp
  Darken = Magick::DarkenCompositeOp # PS equivilent
  Multiply = Magick::MultiplyCompositeOp # PS equivilent
  #ColorBurn
  #LinearBurn
  Lighten = Magick::LightenCompositeOp # PS equivilent
  Screen = Magick::ScreenCompositeOp # PS equivilent
  #ColorDodge
  #LinearDodge
  Overlay = Magick::OverlayCompositeOp # PS equivilent
  #SoftLight
  #HardLight
  #VividLight
  #LinearLight
  #PinLight
  #HardMix
  Difference = Magick::DifferenceCompositeOp # PS equivilent
  #Exclusion
  Hue = Magick::HueCompositeOp
  Saturation = Magick::SaturateCompositeOp
  Color = Magick::ColorizeCompositeOp
  Luminosity = Magick::LuminizeCompositeOp
  
  class Layer
    attr_accessor :image
    attr_reader :offset_x, :offset_y

    def initialize(options = {})
      if options[:file]
        @image = Magick::Image.read(options[:file]).first
        @image.background_color = 'transparent'
      elsif options[:blob]
        @image = Magick::Image.from_blob(options[:blob]).first
        @image.background_color = 'transparent'
      elsif options[:image]
        if options[:image].is_a? Magick::Image
          @image = options[:image]
        end
      end

      if @image
        @image.matte = true
        @mode = Normal
        @offset_x = 0
        @offset_y = 0
        @opacity_percent = 100
        @layer_mask = nil
      else
        raise "Layer not created -- no layer source."
      end
    end

    def layer_mask(options, &block)
      @layer_mask = LayerMask.new options
      
      @layer_mask.instance_eval &block if block_given?
    end

    def merge_down(image)
      @layer_mask.apply self if @layer_mask
      image.composite!(@image, @offset_x, @offset_y, @mode)
    end

    def width
      @image.columns
    end

    def height
      @image.rows
    end

    def offset(x, y)
      @offset_x = x
      @offset_y = y
    end

    def rotate(degrees)
      @image.rotate!(degrees)
    end

    def opacity(percent)
      @opacity_percent = percent
      # intercept original alpha channel with pixel intensity
      alpha_channel = @image.channel(Magick::AlphaChannel).negate
      intensity = (Magick::MaxRGB * (percent/100.0)).round
      alpha_channel.composite!(Magick::Image.new(width, height) { self.background_color = Magick::Pixel.new(intensity,intensity,intensity) }, Magick::CenterGravity, Multiply)
      alpha_channel.matte = false
      
      @image.composite!(alpha_channel, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)
      return true
    end


    def mode(mode = nil)
      return @mode if mode.nil?
      @mode = mode
    end

    def save_as(filename)
      @image.write(filename)
    end
  
    def join_set(set)
      set.add_layer(self)
    end

    def leave_set(set)
      set.remove_layer(self)
    end

  end
end
