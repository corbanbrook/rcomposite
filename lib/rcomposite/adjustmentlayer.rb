module RComposite
  Levels = 1
  Curves = 2
  ColorBalance = 3
  BrightnessContrast = 4
  HueSaturation = 5
  SelectiveColor = 6
  ChannelMixer = 7
  GradientMap = 8
  PhotoFilter = 9
  Invert = 10 # negate
  Threshold = 11 # threshold
  Polarize = 12 # 
  Blur = 13

  class AdjustmentLayer < Layer
    attr_reader :type, :args
    
    def initialize(type, *args, &block)
      @type = type
      @args = args
      @mode = Normal
      @offset_x = 0
      @offset_y = 0
      @opacity_percent = 100
      @layer_mask = nil
      
      case type
        when Invert
          @proc = proc { negate }
        when Threshold    
          @proc = proc { threshold *args }
        when Levels
          @proc = proc { level *args }
        when Blur
          @proc = proc { gaussian_blur *args }
      end
      @proc = proc { |*args| @proc }.call(*@args)
    end

    def merge_down(image)
      @image = image.clone.instance_eval &@proc
      @image.matte = true

      super(image)
    end
  end
end
