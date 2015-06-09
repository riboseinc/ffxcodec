class FFXCodec
  # Example (with encryption):
  #
  #     i = Encoder.new(40, 24)
  #     i.crypto = Encrypt.new("4fb450a9c27dd07f22ef56413432c94a", "FZNT4F22E5QA5QUM")
  #     i.encode(1234567890, 4)      #=> 35031505128447977
  #     i.decode(35031505128447977)  #=> [1234567890, 4]
  #
  # Example (without encryption):
  #
  #     i = Encoder.new(40, 24)
  #     i.encode(1234567890, 4)      #=> 20712612157194244
  #     i.decode(20712612157194244)  #=> [1234567890, 4]
  #
  class Encoder
    UINT64_MAX = 18_446_744_073_709_551_615
    UINT32_MAX = 4_294_967_295

    attr_reader :size, :a_max, :b_max, :type_max
    attr_accessor :debug

    def initialize(a_size = 32, b_size = 32)
      @a_size = a_size
      @b_size = b_size
      @size = a_size + b_size
      @type_max = integer_type_max(size)
      @a_max, @b_max = maximums(a_size, b_size)
    end

    # Add the optional encryption/decryption device
    #
    # Param `device` is expected to have two methods:
    #
    # 1. `device#encrypt(num)`
    # 2. `device#decrypt(num)`
    #
    # Both methods must accept a stringified unsigned integer in base 2 and
    # return a stringified unsigned integer in base 2.
    #
    def crypto=(device)
      @crypto = device
    end

    # Combine two unsigned integers into a single, larger unsigned integer
    #
    # If @crypto is defined, the resulting integer will be encrypted.
    def encode(a, b)
      check_ab_bounds(a, b)
      c = raw_encode(a, b)
      puts "Encoded: #{c} (unencrypted)" if @debug
      check_type_range(c)
      @crypto ? encrypt(c) : c
    end

    def raw_encode(a, b)
      (a << @b_size) ^ b
    end

    # Separate an unsigned integer into two smaller unsigned integers
    #
    # If @crypto is defined, the input will be decrypted before decoding.
    def decode(c)
      c = decrypt(c) if @crypto
      ab = raw_decode(c)
      puts "Decoded: #{ab.inspect}" if @debug
      ab
    end

    def raw_decode(c)
      a = c >> @b_size
      b = (c ^ (a << @b_size))
      [a, b]
    end

    def encrypt(value)
      res = @crypto.encrypt(value.to_s(2))
      enc = res.to_i(2)
      puts "Encoded: #{enc} (encrypted)" if @debug
      check_type_range(enc)  # sanity check
      enc
    end

    def decrypt(value)
      res = @crypto.decrypt(value.to_s(2))
      dec = res.to_i(2)
      puts "Encoded: #{dec} (decrypted)" if @debug
      dec
    end

    private

    def maximums(a_size, b_size)
      a_max = ('1' * a_size).to_i(2)
      b_max = ('1' * b_size).to_i(2)
      [a_max, b_max]
    end

    def check_type_range(value)
      if value > @type_max
        raise "Value exceeds #{@size} bit integer max (#{@type_max}): #{value}"
      end
    end

    def check_ab_bounds(a, b)
      raise ArgumentError, "LHS #{@a_size}-bit value out of bounds: #{a}" if a > @a_max || a < 0
      raise ArgumentError, "RHS #{@b_size}-bit value out of bounds: #{b}" if b > @b_max || b < 0
    end

    def integer_type_max(size)
      case size
      when 32
        UINT32_MAX
      when 64
        UINT64_MAX
      else
        raise ArgumentError, "Combined size must be 32 or 64 bits"
      end
    end
  end
end
