# -*- encoding: utf-8 -*-

module Resque
  module Plugins
    module Bundle

      class Installer
        attr_accessor :common_dependencies, :default_dependencies

        def initialize(config)
          src_cache_path = config[:folder]
          FileUtils.mkdir_p src_cache_path

          #TODO: 
          md5 = "TODO_MD5" #@feature
          feature_cache_path = File.join src_cache_path, md5
          FileUtils.mkdir_p feature_cache_path

          self.common_dependencies = config[:common_dependencies] || []
          self.default_dependencies = config[:default_dependencies] || ["COMMON"]
        end

        def install(dependencies)
          dependencies = replace_common(dependencies || default_dependencies)

          validate_dependencies(dependencies)

          p = Pathname.new("/tmp/username/#{rand(1000000)}") #TODO: use folder and user-name
          FileUtils.mkdir_p(p)
      
          sources = [Bundler::Source::Rubygems.new("remotes" => ["http://gems.github.com"])]
          deps = dependencies.collect do |name|
            name, version = name.split("=>")
            sources.unshift Bundler::Source::Git.new("uri"=>name, "git"=>name)
            Bundler::Dependency.new repo_name(name), version
          end
          definition = Bundler::Definition.new(nil, deps, sources, {})
          definition.resolve_remotely!
      
          Bundler::Installer.install p.to_s, definition
        rescue Bundler::BundlerError => e
          #puts "BUNDLER ERRORED: " + e.inspect
          raise e
        ensure
          #GOTCHA: This is the easiest way i know of to ensure that bundler goes back to the app's root. 
          #Hopefully we won't need/use real --deployment options which would also be deleted
          FileUtils.rm_rf ".bundle" rescue nil
        end

        private
        def replace_common(dependencies)
          if dependencies.include?("COMMON")
            dependencies -= ["COMMON"]
            dependencies += common_dependencies
          end
          dependencies
        end
        def validate_dependencies(array_or_string)
          d = array_or_string.is_a?(String) ? array_or_string.split(",").map(&:strip).select{|step| step[/\w/] } : array_or_string
          unless d.all?{|url| url[/https:\/\/github.com\//] }
            raise "only github https (with production certs) supported. (if you pay me I'll support sooner :)"
          end
          d
        end
      end

      #
      # Returns a Installer instance. usually with specific cache dir
      # Creates a new instance of Installer (obj that wraps bundler api) given a queue name, retrieving
      # configuration from Resque.bundler.
      #
      def bundler
        #TODO: check if bundle is out-of-date?
        config = Resque.bundler
        @installer ||= Installer.new(config)
      end
    end
  end
end

