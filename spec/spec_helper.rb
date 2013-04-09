# -*- encoding: utf-8 -*-
require 'bundler'
require 'rspec'

require 'resque'
require 'resque-bundle'

require 'debugger'
require 'fakefs/spec_helpers'

def ensure_parent_folder_exists(folder=nil)
  FileUtils.mkdir_p File.dirname(folder)
end

def ensure_gemfile
   File.open("Gemfile", "w") { |f| f.puts "source 'http://rubygems.org'" }
end

RSpec.configure do |config|
  Dir[File.join File.dirname(__FILE__), 'support', '**', '*.rb'].each { |f| require f }
  config.include FakeFS::SpecHelpers, fakefs: true
end

