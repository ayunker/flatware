require 'cucumber'
module Flatware
  module Cucumber
    autoload :Formatter, 'flatware/cucumber/formatter'

    extend self
    def features
      @features ||= `find features -name '*.feature' | xargs grep -Hn Scenario | cut -f '1,2' -d ':'`.split "\n"
    end

    def run(options, out, error)
      options = Array(options) + %w[--format Flatware::Cucumber::Formatter]
      cli = ::Cucumber::Cli::Main.new(options, out, error)
      runtime.configure(cli.configuration)

      runtime.instance_eval do
        remove_instance_variable(:@loader) if @loader
        tree_walker = @configuration.build_tree_walker(self)
        self.visitor = tree_walker
        tree_walker.visit_features(features)
      end
    end

    def runtime
      @runtime ||= preload
    end

    private
    def preload
      require 'cucumber' unless defined?(::Cucumber::Cli)
      configuration = ::Cucumber::Cli::Configuration.new
      configuration.parse! []
      runtime = ::Cucumber::Runtime.new(configuration)
      runtime.send :load_step_definitions
      runtime
    end
  end
end
