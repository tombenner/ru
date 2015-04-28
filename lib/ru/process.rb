require 'optparse'

module Ru
  class Process
    def initialize(options={})
      @command_manager = CommandManager.new
      @option_printer  = OptionPrinter.new
    end

    def run
      output = process_options
      return output if output

      args      = ARGV
      first_arg = args.shift

      if first_arg == 'list'
        commands = @command_manager.all
        if commands.present?
          lines = ['Saved commands:']
          lines += commands.sort_by(&:first).map { |name, code| "#{name}\t#{code}" }
        else
          lines = [
            'No saved commands. To save a command, use `save`:',
            "ru save sum 'map(:to_i).sum'"
          ]
        end
        return lines.join("\n")
      elsif first_arg == 'run'
        name  = args.shift
        @code = @command_manager.get(name)
        if @code.blank?
          STDERR.puts "Unable to find command '#{name}'"
          exit 1
          return
        end
      elsif first_arg == 'save'
        name = args[0]
        code = args[1]
        @command_manager.save(name, code)
        return "Saved command: #{name} is '#{code}'"
      elsif first_arg.blank?
        STDERR.puts @option_printer.run(:help)
        exit 1
        return
      else
        @code = first_arg
      end

      @stdin = get_stdin(args, @options[:stream]) unless @code.start_with?('! ')
      @code  = prepare_code(@code) if @code

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
      output  = context.instance_eval(@code) || @stdin
      prepare_output(output)
    end

    private

    def prepare_code(code)
      if code.kind_of?(String)
        if code.start_with?('[')
          code = 'to_self' + code
        elsif code.start_with?('! ')
          code = code[2..-1]
        end
      end
      code
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
        opts.on("-h", "--help", "Print help") do |help|
          options[:help] = true
        end

        opts.on("-v", "--version", "Print version") do |version|
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

    def get_stdin(args, stream)
      paths = args
      if paths.present?
        if stream
          ::File.open(paths[0])
        else
          paths.map { |path| ::File.open(path).read }.join("\n")
        end
      else
        if stream
          STDIN
        else
          STDIN.read
        end
      end
    end
  end
end
