# -*- encoding: utf-8 -*-

module Resque
  module Plugins
    module Bundle

      class Installer
        attr_accessor :dependencies, :common_dependencies, :default_dependencies, 
                      :src_cache_path, :namespace

        def initialize(config)
          self.src_cache_path = Pathname.new(config[:folder])
          FileUtils.mkdir_p src_cache_path.to_s

          #TODO: 
          md5 = "TODO_MD5" #MD5.hexdigest(config[:gherkin])
          feature_cache_path = src_cache_path+md5
          FileUtils.mkdir_p feature_cache_path.to_s

          self.common_dependencies = config[:common_dependencies] || []
          self.default_dependencies = config[:default_dependencies] || ["COMMON"]
        end

        def install
          d = replace_common(dependencies || default_dependencies)
          validate_dependencies(d)
          #raise d.inspect
          do_install(d)
        ensure
          cleanup_install
        end

        #TODO: use folder and namespace
        def do_install(dependencies)
          p = src_cache_path+"#{namespace || "namespace"}/#{rand(1000000)}"
          FileUtils.mkdir_p(p.to_s)
      
          sources = [Bundler::Source::Rubygems.new("remotes" => ["http://gems.github.com"])]
          deps = dependencies.collect do |name|
            #TODO: fragile split. Does Bundler have an internal utility?
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
        end

        def cleanup_install
          #GOTCHA: This is the easiest way i know of to ensure that bundler goes back to the app's root. 
          #Hopefully we won't use .bundle for real.
          FileUtils.rm_rf ".bundle" rescue nil
        end

        private
        def repo_name(name)
          names = name.split(/\W/).reverse
          names.each do |name|
            return name unless name[/^(http|git)s?$/]
          end
        end
        def replace_common(dependencies)
          if dependencies.include?("COMMON")
            dependencies -= ["COMMON"]

            # always add to the beginning 
            dependencies = common_dependencies + dependencies
          end
          dependencies
        end
        def validate_dependencies(array_or_string)
          d = array_or_string.is_a?(String) ? array_or_string.split(",").map(&:strip).select{|step| step[/\w/] } : array_or_string
          unless d.all?{|url| url[/(https|http|git):\/\/github.com\//] }
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

