# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "traco/version"

Gem::Specification.new do |s|
  s.name        = "traco"
  s.version     = Traco::VERSION
  s.authors     = ["Henrik Nyh"]
  s.email       = ["henrik@barsoom.se"]
  s.homepage    = ""
  s.summary     = "Translatable columns for Rails 3 or better, stored in the model table itself."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord", ">= 3.0"

  s.add_development_dependency "sqlite3"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
end
