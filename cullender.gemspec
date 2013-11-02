$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cullender/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cullender"
  s.version     = Cullender::VERSION
  s.authors       = ["Chris Waddington"]
  s.email         = ["cwadding@gmail.com"]
  s.homepage    = "https://github.com/cwadding/cullender"
  s.summary     = "A rails engine to easily integrate elasticsearch percolote feature."
  s.description = "Create reverse queries and add them to elasticsearch to trigger an event any time a new record matches any of the queries."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.1"
  s.add_dependency "tire"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rake"
  s.add_development_dependency 'rspec-rails'#, '~> 2.10.0'
  s.add_development_dependency 'capybara'#, '~> 2.10.0'
end
