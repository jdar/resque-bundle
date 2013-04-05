
Configuration
=============

### Using a initializer
    # config/initializers/resque.rb

    src_cache_path = File.join Rails.root, 'src_cache_path'

    config = {
      folder:     src_cache_path                 # destination folder
    }

    Resque.bundler = config

Usage
=====

### Adding to a resque worker
    # app/workers/my_killer_worker.rb

    class MyKillerWorker
      extend Resque::Plugins::Bundle

      @queue = :my_killer_worker_job

      def self.perform(args = {})
        (...)

        args['dependencies'] ||= ["https://github.com/jdar/codebase", "commongem"]
        bundler.install(args['dependencies'])

        (...)
      end
    end

Dependencies
============

* bundler 

[Resque]: https://github.com/defunkt/resque

Installation
============

### With rubygems:
    $ [sudo] gem install resque-bundle

Authors
=======

* Darius Roberts - <http://dariusroberts.com/>
