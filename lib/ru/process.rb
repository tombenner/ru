module Ru
  class Process
    def initialize(options={})
      @command = options[:command]
      @args = options[:args]
      @stdin = options[:stdin]
      if @command.kind_of?(String) && @command.start_with?('[')
        @command = 'to_stdout' + @command
      end
    end

    def run
      paths = @args
      if @stdin.blank? && paths.present?
        @stdin = paths.map { |path| ::File.open(path).read }.join("\n")
      end
      lines = @stdin.present? ? @stdin.split("\n") : []
      array = Ru::Array.new(lines)
      output = array.instance_eval(@command) || @stdin
      if output.respond_to?(:to_dotsch_output)
        output = output.to_dotsch_output
      end
      if output.kind_of?(::Array)
        output = output.join("\n")
      end
      output.to_s
    end
  end
end
