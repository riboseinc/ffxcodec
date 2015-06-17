require "ffxcodec/version"
require "ffxcodec/core_ext/string"
require "ffxcodec/encrypt"
require "ffxcodec/encoder"

# Encode / decode two integers into a single integer with optional encryption
#
# The resulting value is a single 32 or 64-bit unsigned integer (your choice),
# even when encrypted.
#
# Works by divvying up the bits of the single integer between the two component
# integers and running it through AES-FFX format-preserving cipher (optional).
class FFXCodec
  # @param [Fixnum] a_size the number of bits allocated to the left integer
  # @param [Fixnum] b_size the number of bits allocated to the right integer
  def initialize(a_size, b_size)
    @encoder = Encoder.new(a_size, b_size)
  end

  # Setup encryption
  #
  # Auto-enables encryption after encoding and decryption before decoding.
  #
  # @param [String] key for AES as a hexadecimal string
  # @param [String] tweak for AES
  # @return [void]
  def setup_encryption(key, tweak)
    @crypto = Encrypt.new(key, tweak, @encoder.size, 2)
  end

  # Turn off encryption
  #
  # @return [void]
  def disable_encryption
    @crypto = false
  end

  # Encode two integers into a single integer
  #
  # @param [Fixnum] a value to encode
  # @param [Fixnum] b value to encode
  #
  # @example Encode 40 and 24-bit integers into an unencrypted 64-bit integer
  #   ffx = FFXCodec.new(40, 24)
  #   ffx.encode(1234567890, 4)          #=> 165828720871684
  #
  # @example Encode 40 and 24-bit integers into an encrypted 64-bit integer
  #   ffx = FFXCodec.new(40, 24)
  #   ffx.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "9876543210")
  #   ffx.encode(797980150281, 5427652)  #=> 7692035069140451684
  #
  # @return [Fixnum, Bignum] encoded integer if encryption not setup
  # @return [Fixnum, Bignum] encrypted encoded integer if encryption setup
  def encode(a, b)
    c = @encoder.encode(a, b)
    @crypto ? encrypt(c) : c
  end

  # Decode an integer into its two component integers
  #
  # @note input will automatically be decrypted if encryption was setup
  # @param [Fixnum, Bignum] c value to decode
  #
  # @example Decode unencrypted integer into component 40 and 24-bit integers
  #   ffx = FFXCodec.new(40, 24)
  #   ffx.decode(165828720871684)        #=> [1234567890, 4]
  #
  # @example Decode encrypted integer into component 40 and 24-bit integers
  #   ffx = FFXCodec.new(40, 24)
  #   ffx.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "9876543210")
  #   ffx.decode(7692035069140451684)    #=> [797980150281, 5427652]
  #
  # @return [Array<Fixnum>] component integers
  def decode(c)
    input = @crypto ? decrypt(c) : c
    @encoder.decode(input)
  end

  # Show maximum representable base 10 value for each field
  #
  # @example Maximums for a 32-bit integer split into 24 and 8-bit components
  #   ffx = FFXCodec.new(24, 8)
  #   ffx.maximums  #=> [16777215, 255]
  #
  # @example Maximums for a 64-bit integer split into two 32-bit components
  #   ffx = FFXCodec.new(32, 32)
  #   ffx.maximums  #=> [4294967295, 4294967295]
  #
  # @return [Array<Fixnum>] maximum representable component integers
  def maximums
    [@encoder.a_max, @encoder.b_max]
  end

  private

  # @param [Fixnum, Bignum] value to encrypt
  def encrypt(value)
    @crypto.encrypt(value.to_s(2)).to_i(2)
  end

  # @param [Fixnum, Bignum] value to decrypt
  def decrypt(value)
    @crypto.decrypt(value.to_s(2)).to_i(2)
  end
end
