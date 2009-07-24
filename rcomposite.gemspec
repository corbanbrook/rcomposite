Gem::Specification.new do |s|
  s.name = 'rcomposite'
  s.version = '0.3.0'
  s.date = '2009-7-24'

  s.summary = "An RMagick abstration layer for easy image compositing"
  s.description = ""

  s.authors = ['Corban Brook']
  s.email = 'corbanbrook@gmail.com'
  s.homepage = 'http://github.com/corbanbrook/rcomposite'

  s.files = %w(README MIT-LICENSE lib/rcomposite.rb lib/rcomposite/layer.rb lib/rcomposite/layerset.rb lib/rcomposite/adjustmentlayer.rb lib/rcomposite/filllayer.rb lib/rcomposite/canvas.rb lib/rcomposite/layermask.rb)

  s.add_dependency('rmagick')
end

