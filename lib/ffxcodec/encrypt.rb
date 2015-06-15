require "openssl"

class FFXCodec
  # Implementation of AES-FFX mode format-preserving encryption
  #
  # Cipher device encrypts integers where the resulting ciphertext has the same
  # number of digits in the given base (radix).
  #
  # @note WARNING: This was cooked up as an experimental proof of concept.
  #   It hasn't been tested thoroughly and shouldn't be considered secure.
  #
  # @note Format-preserving != integer-size-preserving in base 10 (see below)
  #
  # The format-preserving characteristic of this cipher is best thought of as
  # preserving the number of digits, not the integer size.  For instance, in
  # base 10, 4294967295 and 4294967296 would be considered to have the same
  # format, but the first is a 32-bit unsigned integer and the second is 64.
  #
  # So given base 10 input that fits within a 32 or 64-bit integer, it's
  # possible for the AES-FFX cipher to return a number that contains the same
  # number of base 10 digits but exceeds the largest number that can be
  # represented in 32 or 64 bits respectively.
  #
  # You can work around this by using radix 2 so that the cipher returns an
  # equal number of bits.  As with all modes, you must supply input as a
  # stringified integer in the base you've specified.
  #
  # Be aware that when you convert between bases, leading zeros are sometimes
  # dropped by the converter.  You must supply the same number of digits to the
  # decrypter as you did to the encrypter or you'll get a different value.  The
  # encrypt and decrypt methods prepend zeros until the input is is of the
  # length specified during initialization.
  #
  class Encrypt
    # @param [Fixnum] radix of the input
    attr_accessor :radix

    # @param [Fixnum] number of rounds of encryption / decryption to run input
    #   through (don't change unless you know what you're doing)
    attr_accessor :rounds

    # @param [Fixnum] length of input
    attr_accessor :length

    # @param [String] tweak for AES
    attr_writer :tweak

    # @param [String] key for AES as a hexadecimal string
    # @param [String] tweak for AES
    # @param [Fixnum] length of the input
    # @param [Fixnum] radix of the input
    def initialize(key, tweak, length, radix = 10)
      @key    = [key].pack('H*')
      @tweak  = tweak
      @radix  = radix
      @length = length
      @rounds = 10
    end

    # @param [String] key for AES as a hexadecimal string
    def key=(key)
      @key = [key].pack('H*')
    end

    # Encrypt
    #
    # @param [String] input unencrypted, stringifed integer of base @radix
    #
    # @example Encrypt
    #   e = Encrypt.new("4fb450a9c27dd07f22ef56413432c94a", "FZNT4F22E5QA5QUM")
    #   e.encrypt(1234567890)  #=> "1224011974"
    #
    # @return [Fixnum, Bignum] encrypted integer
    def encrypt(input)
      a, b = input.zero_pad(@length).bisect
      0.upto(@rounds - 1) do |iter|
        f = feistel_round(input.size, iter, b)
        c = block_addition(a, f)
        a = b
        b = c
      end
      a + b
    end

    # Decrypt
    #
    # @param [String] input encrypted, stringifed integer of base @radix
    #
    # @example Decrypt
    #   e = Encrypt.new("4fb450a9c27dd07f22ef56413432c94a", "FZNT4F22E5QA5QUM")
    #   e.decrypt(1224011974)  #=> "1234567890"
    #
    # @return [Fixnum, Bignum] unencrypted integer
    def decrypt(input)
      a, b = input.zero_pad(@length).bisect
      (@rounds - 1).downto(0) do |iter|
        c = b
        b = a
        f = feistel_round(input.size, iter, b)
        lmin  = [c.size, f.size].min
        a = block_subtraction(lmin, c, f)
      end
      a + b
    end

    private

    # Computes the block-wise radix addition of x and y
    def block_addition(a, b)
      sum = a.to_i(@radix) + b.to_i(@radix)
      sum %= (@radix**a.size)
      sum.to_s(@radix).zero_pad(a.size)
    end

    # Computes the block-wise radix subtraction of x and y
    def block_subtraction(n, x, y)
      diff        = x.to_i(@radix) - y.to_i(@radix)
      mod         = @radix**n
      block_diff  = diff % mod
      block_diff += mod if block_diff < 0
      out         = block_diff.to_s(@radix)
      return out unless out.length < n
      out.zero_pad(n)
    end

    def num_radix(str, length)
      n = str.to_i(@radix)
      n_bitcount = ('0' * (length * 8)) + n.to_s(2)
      n_bitcount = n_bitcount[-(length * 8)..-1]
      [n_bitcount].pack('B*')
    end

    def aes(block)
      aes = OpenSSL::Cipher::Cipher.new('aes-128-cbc')
      aes.encrypt
      aes.key = @key
      aes.update(block)
    end

    def cbc_mac(block)
      fail "invalid block size" unless (block.size % 16 == 0)
      y = "\0" * 16
      i = 0
      while i < block.size
        x = block[i...(i + 16)]
        y = aes(x ^ y)
        i += 16
      end
      y
    end

    def byte_array_to_int(block)
      block.bytes.inject(0) { |memo, b| (memo << 8) + b }
    end

    # Creates the first half of the IV
    #
    # Concatenated with Q in the feistel round.
    #
    # p <- [vers] | [method] | [addition] | [radix] | [rnds(n)] | [split(n)] | [n] | [t]
    def generate_p(input_len)
      vers     = 1
      method   = 2
      addition = 1
      split_n  = input_len / 2
      [vers, method, addition].pack('CCC') +
        [@radix].pack('N')[1..3] +
        [@rounds].pack('C') +
        [split_n].pack('C') +
        [input_len].pack('N') +
        [@tweak.length].pack('N')
    end

    # Creates the second half of the IV
    #
    # Concatenated with P in the feistel round.
    #
    # q <- tweak | [0]^((-t-b-1) mod 16) | [roundNum] | [numradix(B)]
    def generate_q(b, blk_len, round)
      round_num = [round].pack('C')
      @tweak + "\0" * ((-@tweak.size - blk_len - 1) % 16) + round_num + num_radix(b, blk_len)
    end

    # Y <- first d+4 bytes of (Y | AESK(Y XOR [1]16) | AESK(Y XOR [2]16) | AESK(Y XOR [3]16)...)
    def generate_y(blk_len, iv_p, iv_q)
      d = 4 * (blk_len / 4.0).ceil
      y = cbc_mac(iv_p + iv_q)
      byte_array_to_int(y[0...(d + 4)])
    end

    # b <- ceil(ceil(beta * log_2(radix)) / 8)
    def block_length(input_len)
      beta = (input_len / 2.0).ceil
      ((beta * Math.log(@radix) / Math.log(2)).ceil / 8.0).ceil
    end

    # Runs the given block through the modified feistel network
    def feistel_round(input_len, iter, b)
      blk_len = block_length(input_len)
      iv_p = generate_p(input_len)
      iv_q = generate_q(b, blk_len, iter)

      # z = y mod r^m
      y = generate_y(blk_len, iv_p, iv_q)
      m = (iter % 2).zero? ? (input_len / 2) : (input_len / 2.0).ceil
      z = y % (@radix**m)

      z.to_s(@radix).zero_pad(m)
    end
  end
end
