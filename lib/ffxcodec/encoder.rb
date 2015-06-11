class FFXCodec
  # Example (with encryption):
  #
  #   i = Encoder.new(40, 24)
  #   i.crypto = Encrypt.new("4fb450a9c27dd07f22ef56413432c94a", "FZNT4F22E5QA5QUM")
  #   i.encode(1234567890, 4)      #=> 35031505128447977
  #   i.decode(35031505128447977)  #=> [1234567890, 4]
  #
  # Example (without encryption):
  #
  #   i = Encoder.new(40, 24)
  #   i.encode(1234567890, 4)      #=> 20712612157194244
  #   i.decode(20712612157194244)  #=> [1234567890, 4]
  #
  class Encoder
    attr_reader :size, :a_max, :b_max
    attr_accessor :debug

    def initialize(a_size = 32, b_size = 32)
      @a_size = a_size
      @b_size = b_size
      @a_max, @b_max = maximums(a_size, b_size)
      @size = a_size + b_size
      check_size
    end

    # Combine two unsigned integers into a single, larger unsigned integer
    def encode(a, b)
      check_ab_bounds(a, b)
      (a << @b_size) ^ b
    end

    # Separate an unsigned integer into two smaller unsigned integers
    def decode(c)
      a = c >> @b_size
      b = (c ^ (a << @b_size))
      [a, b]
    end

    private

    # Calculate the maximum values representable in the given number of bits
    def maximums(a_size, b_size)
      a_max = ('1' * a_size).to_i(2)
      b_max = ('1' * b_size).to_i(2)
      [a_max, b_max]
    end

    # Raise an error if the given values fall outside our maximums
    def check_ab_bounds(a, b)
      if a > @a_max || a < 0
        fail ArgumentError, "LHS #{@a_size}-bit value out of bounds: #{a}"
      elsif b > @b_max || b < 0
        fail ArgumentError, "RHS #{@b_size}-bit value out of bounds: #{b}"
      end
    end

    # Rase an error if the combined size isn't 32 or 64 bits
    def check_size
      return if @size == 32 || @size == 64
      fail ArgumentError, "Combined size must be 32 or 64 bits"
    end
  end
end
