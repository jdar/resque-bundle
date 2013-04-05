# -*- encoding: utf-8 -*-
require 'bundler'
require 'rspec'

require 'resque'
require 'resque-bundle'

require 'fakefs/spec_helpers'

def ensure_parent_folder_exists(folder=nil)
  FileUtils.mkdir_p File.dirname(folder)
end

RSpec.configure do |config|
  # spec/support files
  Dir[File.join File.dirname(__FILE__), 'support', '**', '*.rb'].each { |f| require f }
end

