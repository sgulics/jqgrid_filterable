# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jqgrid_filterable/version"

Gem::Specification.new do |s|
  s.name        = "jqgrid_filterable"
  s.version     = JqgridFilterable::VERSION
  s.authors     = ["Steve Gulics"]
  s.email       = ["sgulics@gmail.com"]
  s.homepage    = "http://www.gulics.com"
  s.summary     = %q{jqgridFilterable allows the use of the jsGrid plugin's sorting and searching functionality easily with an ActiveRecord model}
  s.description = %q{jqgridFilterable allows the use of the jsGrid plugin's sorting and searching functionality easily with an ActiveRecord model}

  s.rubyforge_project = "jqgrid_filterable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
