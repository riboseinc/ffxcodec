require "ffxcodec/version"
require "ffxcodec/core_ext/string"
require "ffxcodec/encrypt"
require "ffxcodec/encoder"

class FFXCodec
  def initialize(a_size, b_size)
    @encoder = Encoder.new(a_size, b_size)
  end

  def setup_encryption(key, tweak)
    @encoder.crypto = Encrypt.new(key, tweak, @encoder.size, 2)
  end

  def encode(a, b)
    @encoder.encode(a, b)
  end

  def decode(c)
    @encoder.decode(c)
  end

  def maximums
    [@encoder.a_max, @encoder.b_max]
  end
end
