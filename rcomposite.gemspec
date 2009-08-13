Gem::Specification.new do |s|
  s.name = 'rcomposite'
  s.version = '0.3.1'
  s.date = '2009-08-13'

  s.summary = "An RMagick abstration layer for easy image compositing"
  s.description = "Rubyshop is an RMagick abstraction library to easily manipulate and composite images through the use of a canvas, layers, layer masks, adjustment layers, fill layers, and layer sets (much like in Photoshop)"

  s.authors = ['Corban Brook']
  s.email = 'corbanbrook@gmail.com'
  s.homepage = 'http://github.com/corbanbrook/rcomposite'

  s.files = %w{README MIT-LICENSE lib/rcomposite.rb lib/rcomposite/layer.rb lib/rcomposite/layerset.rb lib/rcomposite/adjustmentlayer.rb lib/rcomposite/filllayer.rb lib/rcomposite/canvas.rb lib/rcomposite/layermask.rb}

  s.add_dependency('rmagick', '>= 2.0.0')
  
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
end

