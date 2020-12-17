# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "traco/version"

Gem::Specification.new do |s|
  s.name        = "traco"
  s.version     = Traco::VERSION
  s.authors     = ["Henrik Nyh"]
  s.email       = ["henrik@barsoom.se"]
  s.homepage    = ""
  s.summary     = "Translatable columns for Rails 4.2 or better, stored in the model table itself."
  s.license     = "MIT"

  s.files         = Dir["{lib}/**/*"] + %w[LICENSE.txt]
  s.test_files    = Dir["{spec}/**/*"]
  s.executables   = []
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.3.0"

  s.add_dependency "activerecord", ">= 4.2"

  s.add_development_dependency "sqlite3"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "appraisal"
end
