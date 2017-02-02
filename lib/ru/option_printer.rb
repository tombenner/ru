require 'erb'
require 'ostruct'

module Ru
  class OptionPrinter
    def exists?(option_key)
      ! (options[option_key].nil? || options[option_key].empty?)
    end

    def run(option_key, option_value=nil)
      send(options[option_key], *option_value)
    end

    private

    def options
      {
        help: :get_help,
        version: :get_version
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
