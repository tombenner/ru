module Rushed
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

    def initialize(array)
      @array = array
    end

    def to_a
      Rushed::Array.new(@array)
    end

    def to_dotsch_output
      to_a.join("\n")
    end

    private

    def method_missing(method, *args, &block)
      map_method(method, *args, &block)
    end

    def map_method(method, *args, &block)
      @array.map! { |item| item.send(method, *args, &block) }
      self
    end

    redefined_methods.each do |method|
      define_method(method) do |*args|
        map_method(method, *args)
      end
    end
  end
end
