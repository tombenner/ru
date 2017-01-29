require 'optparse'

module Ru
  class Process

    def initialize
      @option_printer = OptionPrinter.new
    end

    def run
      output = process_options
      return output if output

      args  = ARGV.dup
      @code = args.shift

      if @code.blank?
        $stderr.puts @option_printer.run(:help)
        return
      end

      @parsed = prepare_code(@code)
      @stdin  = get_stdin(args, @options[:stream]) if @parsed[:get_stdin]

      context =
        if @stdin.nil?
          Ru::Array.new([])
        else
          if @options[:stream]
            if @options[:binary]
              Ru::Stream.new(@stdin.each_byte.lazy)
            else
              Ru::Stream.new(@stdin.each_line.lazy.map { |line| line.chomp("\n".freeze) })
            end
          else
            if @options[:binary]
              Ru::Array.new(@stdin.bytes)
            else
              # Prevent 'invalid byte sequence in UTF-8'
              @stdin.encode!('UTF-8', 'UTF-8', invalid: :replace)
              Ru::Array.new(@stdin.split("\n"))
            end
          end
        end

      output = context.instance_eval(@parsed[:code])
      output = @stdin if output == nil

      prepare_output(output)
    end

    private

    def prepare_code(code)
      return code unless code.kind_of?(String)
      if code.start_with?('[')
        { code: "to_self#{code}", get_stdin: true }
      elsif code.start_with?('=')
        { code: code[1..-1], get_stdin: false }
      elsif code.start_with?('!')
        ActiveSupport::Deprecation.warn %('!1+2' syntax is going to be replaced with '=1+2')
        { code: code[1..-1], get_stdin: false }
      else
        { code: code, get_stdin: true }
      end
    end

    def prepare_output(output)
      if output.respond_to?(:to_stdout)
        output = output.to_stdout
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
        opts.on("-h", "--help", "Print help") do
          options[:help] = true
        end

        opts.on("-v", "--version", "Print version") do
          options[:version] = true
        end

        opts.on('-s', '--stream', 'Stream mode') do
          options[:stream] = true
        end

        opts.on('-b', '--binary', 'Binary mode') do
          options[:binary] = true
        end
      end.parse!
      options
    end

    def get_stdin(paths, stream)
      if paths.present?
        if stream
          ::File.open(paths[0])
        else
          paths.map { |path| ::File.read(path) }.join("\n")
        end
      else
        if stream
          $stdin
        else
          $stdin.read
        end
      end
    end
  end
end
