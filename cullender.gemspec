$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cullender/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cullender"
  s.version     = Cullender::VERSION
  s.authors       = ["Chris Waddington"]
  s.email         = ["cwadding@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Cullender."
  s.description = "TODO: Description of Cullender."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.0.beta1"
  s.add_dependency "tire"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rake"
  s.add_development_dependency 'rspec-rails'#, '~> 2.10.0'
  s.add_development_dependency 'capybara'#, '~> 2.10.0'
end
