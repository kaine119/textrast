Gem::Specification.new do |s|
  s.name        = 'textrast'
  s.version     = '0.2.0'
  s.date        = '2018-02-23'
  s.summary     = "Text Rasteriser"
  s.description = "Rasterises text in square images and saves it to a local file."
  s.authors     = ["Mui Kai En"]
  s.email       = 'muikaien1@gmail.com'
  s.files       = ["lib/textrast.rb"]
  s.license       = 'MIT'
  s.add_runtime_dependency "rmagick", "~> 2.16.0"
end