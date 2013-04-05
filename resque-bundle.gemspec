# -*- encoding: utf-8 -*-

$:.push File.expand_path('../lib', __FILE__)
require 'resque_bundle/version'

Gem::Specification.new do |s|
  s.name        = 'resque-bundle'
  s.version     = ResqueBundle::VERSION
  s.authors     = ['Darius Roberts']
  s.email       = ['darius.roberts@gmail.com']
  s.homepage    = 'https://github.com/jdar/resque-bundle'
  s.summary     = %q{A Resque plugin to provide on-the-fly dependency gem updates for each worker}
  s.description = %q{update dependencies on the fly from github for Resque workers.}

  s.rubyforge_project = 'resque-bundle'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency  'rake'
  s.add_development_dependency  'rspec'
  s.add_development_dependency  'fakefs'
  s.add_runtime_dependency      'resque'
end
