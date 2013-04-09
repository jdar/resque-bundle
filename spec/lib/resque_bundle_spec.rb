# -*- encoding: utf-8 -*-

require 'spec_helper'

describe ResqueBundle do
  include RSpecMacros


  describe 'checking configured values' do
    it 'raises an error if folder parent does not exist' do
      expect { Resque.bundler = config }.to raise_error(Errno::ENOENT, "Cache directory does not exist.")
    end    

    it 'raises an error if folder is not found' do
      config.delete :folder

      error = ArgumentError.new 'Folder must be supplied'

      expect { Resque.bundler = config }.to raise_error(error.class, error.message)
    end

    it 'not raises otherwise' do
      ensure_parent_folder_exists config[:folder]
      expect { Resque.bundler = config }.to_not raise_error
    end
  end
end

