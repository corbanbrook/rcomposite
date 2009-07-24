module RComposite
  class LayerMask < Layer
    def apply(layer)
      # apply layer mask to layer before merging down
      fill = Magick::GradientFill.new(0,0,0,0, '#000', '#000')
      mask = Magick::Image.new(layer.width, layer.height, fill)
      mask.composite!(@image, @offset_x, @offset_y, Magick::OverCompositeOp)
      
      alpha_channel = layer.image.channel(Magick::AlphaChannel).negate
      alpha_channel.composite!(mask, 0, 0, Magick::MultiplyCompositeOp)
      alpha_channel.matte = false
      layer.image.composite!(alpha_channel, 0, 0, Magick::CopyOpacityCompositeOp)
    end
  
  end
end
