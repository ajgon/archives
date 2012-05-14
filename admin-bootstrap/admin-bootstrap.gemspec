$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "admin-bootstrap/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "admin-bootstrap"
  s.version     = AdminBootstrap::VERSION
  s.authors     = ["Igor Rzegocki"]
  s.email       = ["ajgon@irgon.com"]
  s.homepage    = "https://github.com/ajgon/admin-bootstrap"
  s.summary     = "A nice scaffolding module compatible with Twitter Bootstrap"
  s.description = s.summary

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*", "spec/**/*"]

  s.add_dependency "rails", "~> 3.2.3"

  s.add_development_dependency "sqlite3"
end
