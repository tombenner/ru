require 'optparse'

module Ru
  class Process
    def initialize(options={})
      @option_printer = OptionPrinter.new
    end

    def run
      output = process_options
      return output if output

      args = ARGV
      first_arg = args.shift

      if first_arg.blank?
        STDERR.puts @option_printer.run(:help)
        exit 1
      end

      @code = prepare_code(first_arg)
      @stdin = get_stdin(args)
      lines = @stdin.present? ? @stdin.split("\n") : []
      array = Ru::Array.new(lines)
      output = array.instance_eval(@code) || @stdin
      output = prepare_output(output)
      output
    end

    private

    def prepare_code(code)
      if code.kind_of?(String)
        if code.start_with?('[')
          code = 'to_stdout' + code
        elsif code.start_with?('! ')
          code = code[2..-1]
        end
      end
      code
    end

    def prepare_output(output)
      if output.respond_to?(:to_dotsch_output)
        output = output.to_dotsch_output
      end
      if output.kind_of?(::Array)
        output = output.join("\n")
      end
      output.to_s
    end

    def process_options
      @options = get_options
      @options.each do |option, value|
        if @option_printer.exists?(option)
          return @option_printer.run(option)
        end
      end
      nil
    end

    def get_options
      options = {}
      OptionParser.new do |opts|
        opts.on("-h", "--help", "Print help") do |help|
          options[:help] = true
        end

        opts.on("-v", "--version", "Print version") do |version|
          options[:version] = true
        end
      end.parse!
      options
    end

    def get_stdin(args)
      paths = args
      if paths.present?
        paths.map { |path| ::File.open(path).read }.join("\n")
      else
        STDIN.read
      end
    end
  end
end
