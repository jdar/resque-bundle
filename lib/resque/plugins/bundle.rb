# -*- encoding: utf-8 -*-

module Resque
  module Plugins
    module Bundle
      #
      # Returns a Bundler::Installer instance. usually with specific cache dir
      #
      def bundler
        #TODO: check if bundle is out-of-date?
        @installer ||= create_bundler
      end

      private

      #
      # Creates a new instance of bundler given a queue name, retrieving
      # configuration from Resque.bundler.
      #
      def create_bundler
        config = Resque.bundler
        
        src_cache_path = config[:folder]
        FileUtils.mkdir src_cache_path

        #TODO: 
        md5 = "TODO_MD5" #@feature
        feature_cache_path = File.join src_cache_path, md5
        FileUtils.mkdir feature_cache_path

        #TODO
        bundler = Bundler::Installer.new(feature_cache_path)

        bundler
      end
    end
  end
end

