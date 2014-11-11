module Ru
  class Array
    def initialize(array)
      @data = array.to_a
    end

    def each_line
      Ru::Iterator.new(self)
    end

    def files
      @data.map! do |line|
        Ru::File.new(line)
      end
      self
    end

    def format(format='l')
      @data.map! do |item|
        item.format(format)
      end
      self
    end

    def grep(pattern)
      if pattern.kind_of?(String)
        pattern = Regexp.new(pattern)
      end
      select! do |item|
        item.to_s =~ pattern
      end
      self
    end

    def map(method=nil, *args, &block)
      if method.nil? && !block_given?
        to_a.map
      elsif method.nil?
        array = to_a.map(&block)
        self.class.new(array)
      else
        array = to_a.map { |item| item.send(method, *args) }
        self.class.new(array)
      end
    end

    def select(*args, &block)
      delegate_to_array(:select, *args, &block)
    end

    def to_stdout
      self
    end

    def to_a
      @data
    end

    def to_ary
      to_a
    end

    def to_s
      self.to_a.join("\n")
    end

    def ==(other)
      self.to_a == other.to_a
    end

    def method_missing(method, *args, &block)
      delegate_to_array(method, *args, &block)
    end

    private

    def delegate_to_array(method, *args, &block)
      result = to_a.send(method, *args, &block)
      if result.kind_of?(Enumerable)
        self.class.new(result)
      else
        result
      end
    end
  end
end
