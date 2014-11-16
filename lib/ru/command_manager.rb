require 'pathname'

module Ru
  class CommandManager
    class InvalidCodeError < ArgumentError; end
    class InvalidNameError < ArgumentError; end

    def save(name, code)
      raise InvalidCodeError.new("Invalid code. Code cannot be blank.") if code.blank?
      validate_name(name)
      commands = get_commands
      commands[name] = code
      save_commands(commands)
    end

    def get(name)
      validate_name(name)
      commands = get_commands
      commands[name]
    end

    private

    def save_commands(commands)
      lines = []
      commands.each do |name, code|
        lines << "#{name},#{code}"
      end
      content = lines.join("\n")
      ::File.open(path, 'w') { |file| file.write(content) }
    end

    def get_commands
      if ::File.exists?(path)
        commands = {}
        ::File.readlines(path).each do |line|
          pieces = line.chomp.split(',', 2)
          commands[pieces[0]] = pieces[1]
        end
        commands
      else
        {}
      end
    end

    def validate_name(name)
      if name !~ /^[\w_]+$/
        raise InvalidNameError.new("Invalid command name '#{name}'. Command names may only contain alphanumerics and underscores.")
      end
    end

    def path
      Pathname.new(::File.expand_path('~')).join('.ru_commands')
    end
  end
end
