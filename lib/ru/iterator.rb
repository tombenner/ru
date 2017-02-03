module Ru
  class Iterator
    class << self
      def redefined_methods
        @redefined_methods ||= begin
          preserved_methods = %{initialize method_missing respond_to? to_a}
          [].public_methods.select do |method|
            method = method.to_s
            method =~ /^[a-z]/ && !preserved_methods.include?(method)
          end
        end
      end
    end

    def initialize(enum)
      @enum = enum
    end

    def to_a
      case @enum
      when ::Array
        Ru::Array.new(@enum)
      when Ru::Array
        @enum
      when Ru::Stream
        @enum.to_a
      end
    end

    def to_stdout
      case @enum
      when ::Array
        @enum.join("\n")
      else
        @enum.to_s
      end
    end

    private

    def method_missing(method, *args, &block)
      map_method(method, *args, &block)
    end

    def map_method(method, *args, &block)
      @enum = @enum.map { |item| item.send(method, *args, &block) }
      self
    end

    redefined_methods.each do |method|
      define_method(method) do |*args|
        map_method(method, *args)
      end
    end
  end
end
