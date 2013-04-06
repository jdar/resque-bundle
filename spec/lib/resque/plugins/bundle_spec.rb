# -*- encoding: utf-8 -*-

require 'spec_helper'

describe Resque::Plugins::Bundle do #, fakefs: true do
  @worker_queue = :worker_queue

  class ResqueWorker 
    extend Resque::Plugins::Bundle

    @queue = @worker_queue

    def self.perform(args = {})
      bundler.install args['dependencies']
    end
  end

  let(:cache_dir)     { File.join config[:folder], "feature_cache_dir" }
  let(:bundle_mock)   { mock Bundler } #Bundler::Installer

  let(:config) do
    {
      folder:     '/tmp/path/to/your/cache/folder',
      default_dependencies: ['https://github.com/jdar/steps.git']
    }
  end

  before :each do
    Resque.stub(:bundler).and_return(config)
    bundle_mock.should_receive(:install).any_number_of_times
    ensure_parent_folder_exists config[:folder]

    # FIXME: find a better way to test
    ResqueWorker.instance_variable_set :@installer, nil
  end

  describe 'when no dependencies' do
    it 'fails to find Gemfile' do
      pending "change error message to 'supply dependencies'"
    end
  end

  describe 'getting a bundle based on arg' do
    it 'creates a bundle based on configuration' do
      Bundler::Installer.should_receive(:install). #.with(cache_dir, config[:class_args].first, config[:class_args].last)
        and_return(bundle_mock)

      ResqueWorker.perform
    end

    it 'returns a previously created bundle' do
      Bundler::Installer.stub(:new).and_return(bundle_mock)
      ResqueWorker.perform

      Bundler::Installer.should_not_receive(:new)
      ResqueWorker.perform
    end
  end
end

