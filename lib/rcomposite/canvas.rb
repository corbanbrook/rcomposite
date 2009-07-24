module RComposite
  class Canvas < LayerSet
    attr_reader :width, :height
    attr_accessor :image

    def initialize(width, height, &block)
      @image = Magick::Image.new width, height
      @width = width
      @height = height
      $RCompositeCanvasWidth = @width
      $RCompositeCanvasHeight = @height

      super(:canvas, &block)
    end
  end
end
