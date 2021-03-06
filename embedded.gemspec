$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "embedded/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "embedded"
  s.version     = Embedded::VERSION
  s.authors     = ["jvillarejo"]
  s.email       = ["arzivian87@gmail.com"]
  s.homepage    = "https://github.com/jvillarejo/embedded"
  s.summary     = "Use value objects with activerecord objects"
  s.description = "Rails plugin that makes value objects embedded into activerecord objects"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'activerecord', ">= 3.2"
  
  s.add_development_dependency "bundler", "~> 1.13"
  s.add_development_dependency "rake", ">= 12.3"
  s.add_development_dependency "minitest", ">= 5.11"
  s.add_development_dependency "sqlite3", ">= 1.3"
end
