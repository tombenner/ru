require 'erb'

# TODO: If more options are added, we should use OptionParser
module Ru
  class Options
    def exists?(option_key)
      options[option_key].present?
    end

    def run(option_key, option_value=nil)
      send(options[option_key], *option_value)
    end

    private

    def options
      {
        '-h' => :get_help,
        '--help' => :get_help,
        '-v' => :get_version,
        '--version' => :get_version
      }
    end

    def get_help
      namespace = OpenStruct.new(version: Ru::VERSION)
      template_path = ::File.expand_path("../../../doc/help.erb", __FILE__)
      template = ::File.open(template_path).read
      ERB.new(template).result(namespace.instance_eval { binding })
    end

    def get_version
      Ru::VERSION
    end
  end
end
