# -*- encoding: utf-8 -*-

require 'spec_helper'

describe Resque::Plugins::Bundle, fakefs: true do
  BI = Resque::Plugins::Bundle::Installer 

  @worker_queue = :worker_queue

  class ResqueWorker 
    extend Resque::Plugins::Bundle

    @queue = @worker_queue

    def self.perform(args = {})
      bundler.dependencies = args['dependencies']
      #bundler.namespace = args['username']
      bundler.install
    end
  end

  let(:cache_dir)     { File.join config[:folder], "feature_cache_dir" }
  let(:definition_mock)   { mock Bundler::Definition }
  let(:foo)   { "https://github.com/jdar/foo" }
  let(:bar)   { "https://github.com/jdar/bar.git" }
  let(:baz)   { "git://github.com/jdar/baz" }

  let(:config) do
    {
      folder:     '/tmp/path/to/your/cache/folder',
      common_dependencies: []
    }
  end

  before :each do
    ensure_gemfile
    Resque.stub(:bundler).and_return(config)
    Bundler::Definition.stub :new=>definition_mock
    definition_mock.stub :resolve_remotely! => "..."

    ensure_parent_folder_exists config[:folder]

    ResqueWorker.instance_variable_set :@installer, nil
  end

  describe 'when no dependencies' do
    it 'clears pre-existing bundle' do
      BI.any_instance.should_receive(:do_install).with([])
      ResqueWorker.perform('dependencies'=>[])
      #expect(File.open cache_dir).to exist #TODO: and be empty
    end

    it 'uses default_dependencies' do
      config[:default_dependencies] = [baz]
      BI.any_instance.should_receive(:do_install).with([baz])
      ResqueWorker.perform('dependencies'=>nil)
    end 
  end

  #TODO: this could be better separated
  describe 'when "COMMON" dependencies exist' do
    it 'substitutes into dependencies arg' do
      config[:common_dependencies] = [foo,bar]
      
      pending "not sure why code is calling 'do_install' for this one..."
      BI.should_receive(:do_install).with([foo,bar])
      ResqueWorker.perform('dependencies'=>nil)
    end
    it 'defaults to default instead of common' do
      config[:common_dependencies] = [foo, bar]
      config[:default_dependencies] = [baz, "COMMON"]

      BI.any_instance.should_receive(:do_install).with([foo,bar,baz])
      ResqueWorker.perform('dependencies'=>nil)
    end 
    it 'overridden by dependencies' do
      config[:common_dependencies] = [foo]
      config[:default_dependencies] = [bar]

      BI.any_instance.should_receive(:do_install).with([foo,baz])
      ResqueWorker.perform('dependencies'=>[baz, "COMMON"])
    end 
    
  end

  describe 'getting a bundle based on arg' do
    it 'creates a bundle based on configuration' do
      Bundler::Installer.should_receive(:install).with(any_args()) #TODO cache_dir, )

      ResqueWorker.perform
    end
    it 'returns a previously created bundle' do
      pending "memoization or per-user caching. what is the right basis?"
      Bundler::Installer.should_receive(:install).with(any_args())
      ResqueWorker.perform

      Bundler::Installer.should_not_receive(:install)
      ResqueWorker.perform
    end
  end
end

