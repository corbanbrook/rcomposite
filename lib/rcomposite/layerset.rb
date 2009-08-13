module RComposite
  class LayerSet
    attr_accessor :layers
    attr_reader :min_x, :min_y, :max_x, :max_y, :bounding_width, :bounding_height, :name
    
    def initialize(name, &block)
      @layers = []

      bounding_box
      @name = name

      self.instance_eval &block if block_given?
    end

    def stack(&block)
      self.instance_eval &block if block_given?
    end

    def layer_set(ref, position = :bottom, &block) 
      if ref.is_a? RComposite::LayerSet
        # referencing a previously instanstiated LayerSet.
        set = ref 
      else    
        # creating a new LayerSet
        set = LayerSet.new ref  
      end     
      
      # Add layer set to render pipeline
      if position == :bottom
        @layers << set
      elsif position == :top
        @layers.unshift set
      end

      # tie floating block methods (layer, rotate, offset, etc) to LayerSet object.
      set.instance_eval &block if block_given?

      return set
    end
    
    def layer(options, &block) 
      if options.is_a? RComposite::Layer
        layer = options
      else
        layer = Layer.new options
      end

      # Add layer to render pipeline
      @layers << layer

      # tie floating block methods (opacity, mode, offset, etc) to Layer object.
      layer.instance_eval &block if block_given?

      return layer
    end

    def fill_layer(type, *args, &block)
      layer = FillLayer.new type, *args
      @layers << layer

      # tie floating block methods (opacity, mode, offset, etc) to Layer object.
      layer.instance_eval &block if block_given?

      return layer
    end

    def adjustment_layer(type, *args, &block) 
      layer = AdjustmentLayer.new type, *args
      @layers << layer

      # tie floating block methods (opacity, mode, offset, etc) to Layer object.
      layer.instance_eval &block if block_given?
    
      return layer
    end
    
    def flatten
      flattened_image = render
      
      # clear layers and sets
      @layers.clear

      # only 1 flattened layer now   
      @layers << Layer.new(flattened_image)
   end

    def render
      return composite_layers(@image.clone, @layers)
    end

    def composite_layers(image, layers) 
      layers.reverse.each do |layer| 
        case layer
          when RComposite::LayerSet
            image = composite_layers image, layer.layers
          when RComposite::Layer
            layer.merge_down image
        end     
      end     
      
      return image
    end
  
    def save_as(filename)
      render.write(filename)
    end

################################################################################################################################

    def add_layer(layer)
      @layers << layer
      bounding_box
    end

    def remove_layer(layer)
      @layers.delete(layer)
      bounding_box
    end

    def bounding_box
      if @layers.size > 0
        x1 = []
        y1 = []
        x2 = []
        y2 = []
        @layers.each do |layer|
          x1 << layer.offset_x
          y1 << layer.offset_y
          x2 << layer.width + layer.offset_x 
          y2 << layer.height + layer.offset_y 
        end

        @min_x = x1.min
        @min_y = y1.min
        @max_x = x2.max
        @max_y = y2.max
        @bounding_width = @max_x - @min_x
        @bounding_height = @max_y - @min_y
      else
        @min_x = 0
        @min_y = 0
        @max_x = 0
        @max_y = 0
        @bounding_width = 0
        @boudning_height = 0
      end
    end
  
    def offset(x, y)
      bounding_box # recalculate bounding box
      shift_x = x - @min_x
      shift_y = y - @min_y
      @layers.each do |layer|
        layer.offset(layer.offset_x + shift_x, layer.offset_y + shift_y)
      end
      bounding_box
    end

    def scale(width, height)
      bounding_box # recalculate bounding box
      width_scale = width.to_f / bounding_width.to_f
      height_scale = height.to_f / bounding_height.to_f
      @layers.each do |layer|
        layer.image.scale!((layer.width * width_scale).round, (layer.height * height_scale).round) 
        layer.offset(((layer.offset_x - @min_x) * width_scale).round + @min_x, ((layer.offset_y - @min_y) * height_scale).round + @min_y)
      end
      bounding_box
    end
    
    def rotate(degrees)
      bounding_box # recalculate bounding box
      bounding_mid_x = @bounding_width / 2
      bounding_mid_y = @bounding_height / 2
      @layers.each do |layer|
        layer_mid_x = (layer.width/2.0).round + layer.offset_x - @min_x - bounding_mid_x
        layer_mid_y = ((layer.height/2.0).round + layer.offset_y - @min_y - bounding_mid_y) * -1

        radians = (degrees * -1) / (180 / Math::PI)
        
        cos = Math.cos(radians)
        sin = Math.sin(radians)

        new_mid_x = ((layer_mid_x * cos) - (layer_mid_y * sin)).round
        new_mid_y = ((layer_mid_x * sin) + (layer_mid_y * cos)).round
      
        layer.rotate(degrees)

        new_offset_x = new_mid_x - (layer.width/2.0).round + @min_x + bounding_mid_x
        new_offset_y = new_mid_y * -1 - (layer.height/2.0).round + @min_y + bounding_mid_y

        layer.offset(new_offset_x, new_offset_y)
      end
      bounding_box
    end
  end
end
