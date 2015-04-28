class Enumerator::Lazy
  def [](number_or_range, length=1)
    if number_or_range.kind_of? Range
      range = number_or_range
      if range.begin < 0 || range.end < -1 || (range.exclude_end? && range.end == -1)
        raise ArgumentError, "Stream doesn't support negative indexes, except x..-1"
      end
      if range.end == -1
        drop(range.begin)
      else
        each_with_index.select { |_, index|
          range.cover?(index)
        }
      end
    else
      number = number_or_range
      if number >= 0
        result = drop(number)
        if length >= 0
          result.take(length)
        else
          nil
        end
      else
        raise ArgumentError, "Stream doesn't support negative indexes"
      end
    end
  end

  def length
    count
  end

  def uniq
    seen = Set.new
    select { |item|
      seen.add?(item)
    }
  end
end

module Ru
  class Stream

    attr :stream

    # @param [Enumerator::Lazy] stream
    def initialize(stream)
      raise ArgumentError unless stream.kind_of? Enumerator::Lazy
      @stream = stream
    end

    def each_line
      Ru::Iterator.new(self)
    end

    def files
      self.class.new @stream.map { |line| Ru::File.new(line) }
    end

    def format(format='l')
      self.class.new @stream.map { |item| item.format(format) }
    end

    def grep(pattern)
      if pattern.kind_of? String
        pattern = Regexp.new(pattern)
      end
      self.class.new @stream.select { |item| item.to_s =~ pattern }
    end

    def map(method=nil, *args, &block)
      if method.nil? && !block_given?
        each_line
      elsif method.nil?
        self.class.new @stream.map(&block)
      else
        self.class.new @stream.map { |item| item.send(method, *args) }
      end
    end

    def select(*args, &block)
      self.class.new @stream.select(*args, &block)
    end

    def to_a
      Ru::Array.new(@stream.to_a)
    end

    alias_method :to_ary, :to_a

    def to_s
      result = ''
      result.concat @stream.next.to_s
      loop do
        item = @stream.next.to_s
        result.concat "\n".freeze
        result.concat item
      end
      result
    rescue StopIteration
      result
    end

    def to_self
      self
    end

    def ==(other)
      other.is_a?(self.class) && self.stream == other.stream
    end

    private

    def method_missing(method, *args, &block)
      result = @stream.send(method, *args, &block)
      if result.kind_of? Enumerator::Lazy
        self.class.new(result)
      elsif result.kind_of? ::Array
        Ru::Array.new(result)
      else
        result
      end
    end
  end
end
