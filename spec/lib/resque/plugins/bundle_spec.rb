# -*- encoding: utf-8 -*-

require 'spec_helper'

describe Resque::Plugins::Bundle do
  include FakeFS::SpecHelpers
  @worker_queue = :worker_queue

  class ResqueWorker 
    extend Resque::Plugins::Bundle

    @queue = @worker_queue

    def self.perform(args = {})
      # TODO: default and shared options?
      # dependencies = ResqueBundle.common_dependencies + (args['dependencies'] || ResqueBundle.default_dependencies)
      dependencies = args['dependencies'] || []
      bundler.install dependencies
    end
  end

  let(:cache_dir)     { File.join config[:folder], "feature_cache_dir" }
  let(:bundle_mock)   { mock Bundler } #Bundler::Installer

  let(:config) do
    {
      folder:     '/tmp/path/to/your/cache/folder'
    }
  end

  before :each do
    Resque.stub(:bundler).and_return(config)
    bundle_mock.should_receive(:install).any_number_of_times
    ensure_parent_folder_exists config[:folder]

    # FIXME: find a better way to test
    ResqueWorker.instance_variable_set :@installer, nil
  end

  describe 'getting a bundle based on queue' do
    before :each do
      config.delete :level
      config.delete :formatter
    end

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

    it 'accepts a bundle without additional args' do
      config.delete :class_args

      Bundler::Installer.should_receive(:new).with(cache_dir).and_return(bundle_mock)

      ResqueWorker.perform
    end
  end

  describe 'setting bundle options from configuration' do
    before :each do
      Bundler::Installer.stub(:new).and_return(bundle_mock)
    end

    #TODO: use foler, not formatter.
    it 'configures bundle level if informed' do
      config.delete :formatter

      bundle_mock.should_receive(:level=).with(config[:level])

      ResqueWorker.perform
    end

  end
end

