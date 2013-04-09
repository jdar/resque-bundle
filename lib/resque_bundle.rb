# -*- encoding: utf-8 -*-

require "resque_bundle/version"
require "resque/setup"

module ResqueBundle
  module ClassMethods
    def bundler
      @installer
    end

    #
    # Configures ResqueBundler with the following hash:
    # {
    #   folder: <folder location for code cache>
    # }
    #
    # Hash keys will be symbols to work.
    #
    def bundler=(options)
      check_installer_args! options

      @installer = options
    end

    private

    #
    # Check for necessary keys and raises if not found.
    #
    def check_installer_args!(options)
      keys = options.keys

      raise ArgumentError.new 'Folder must be supplied' unless keys.include?(:folder)
      raise Errno::ENOENT.new 'Cache directory does not exist.' unless File.exist?(options[:folder].to_s)
    end
  end
end

Resque.extend ResqueBundle::ClassMethods
