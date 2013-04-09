# -*- encoding: utf-8 -*-

require 'spec_helper'

describe ResqueBundle, fakefs: true do
  include RSpecMacros

  describe 'checking configured values' do
    it 'raises an error if folder parent does not exist' do
      error = Errno::ENOENT.new "Cache directory does not exist."
      expect { Resque.bundler = config }.to raise_error(error.class, error.message)
    end    

    it 'raises an error if folder is not found' do
      config.delete :folder

      error = ArgumentError.new 'Folder must be supplied'
      expect { Resque.bundler = config }.to raise_error(error.class, error.message)
    end

    it 'passes if valid' do
      ensure_parent_folder_exists config[:folder]
      expect { Resque.bundler = config }.to_not raise_error
    end
  end
end

