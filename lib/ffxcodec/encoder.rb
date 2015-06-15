class FFXCodec
  # Encode two integers into one larger integer and decode back
  class Encoder
    # @return [Fixnum] size of encoded integer in bits (32 or 64)
    attr_reader :size

    # @return [Fixnum] maximum unsigned value representable by left integer
    attr_reader :a_max

    # @return [Fixnum] maximum unsigned value representable by right integer
    attr_reader :b_max

    # @param [Fixnum] a_size the number of bits allocated to the left integer
    # @param [Fixnum] b_size the number of bits allocated to the right integer
    def initialize(a_size = 32, b_size = 32)
      @a_size = a_size
      @b_size = b_size
      @a_max, @b_max = maximums(a_size, b_size)
      @size = a_size + b_size
      check_size
    end

    # Combine two unsigned integers into a single, larger unsigned integer
    #
    # @param [Fixnum] a value to encode
    # @param [Fixnum] b value to encode
    #
    # @example Encode 40 and 24-bit integers into a single 64-bit integer
    #   i = Encoder.new(40, 24)
    #   i.encode(1234567890, 4)      #=> 20712612157194244
    #
    # @return [Fixnum, Bignum] encoded integer
    def encode(a, b)
      check_ab_bounds(a, b)
      (a << @b_size) ^ b
    end

    # Separate an unsigned integer into two smaller unsigned integers
    #
    # @example Decode an encoded 64-bit integer into 40 and 24-bit integers
    #   i = Encoder.new(40, 24)
    #   i.decode(20712612157194244)  #=> [1234567890, 4]
    #
    # @param [Fixnum, Bignum] c encoded value to decode
    # @return [Array<Fixnum>] decoded integers
    def decode(c)
      a = c >> @b_size
      b = (c ^ (a << @b_size))
      [a, b]
    end

    private

    # Calculate the maximum values representable in the given number of bits
    #
    # @param [Fixnum] a_size number of bits allocated to left integer
    # @param [Fixnum] b_size number of bits allocated to right integer
    # @return [Array<Fixnum>] maximum representable values for each integer
    def maximums(a_size, b_size)
      a_max = (1 << a_size) - 1
      b_max = (1 << b_size) - 1
      [a_max, b_max]
    end

    # @param [Fixnum] a left integer to be encoded
    # @param [Fixnum] b right integer to be encoded
    # @raise [ArgumentError] if the given values fall outside our maximums
    # @return [void]
    def check_ab_bounds(a, b)
      if a > @a_max || a < 0
        fail ArgumentError, "LHS #{@a_size}-bit value out of bounds: #{a}"
      elsif b > @b_max || b < 0
        fail ArgumentError, "RHS #{@b_size}-bit value out of bounds: #{b}"
      end
    end

    # @raise [ArgumentError] if the combined bit count isn't 32 or 64 bits
    # @return [void]
    def check_size
      return if @size == 32 || @size == 64
      fail ArgumentError, "Combined size must be 32 or 64 bits"
    end
  end
end
