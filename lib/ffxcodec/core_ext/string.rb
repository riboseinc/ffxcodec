class String
  def ^(other)  # xor
    b1 = self.unpack("C*")
    b2 = other.unpack("C*")
    raise "Strings must be the same length" unless b1.size == b2.size
    longest = [b1.length, b2.length].max
    b1 = [0] * (longest - b1.length) + b1
    b2 = [0] * (longest - b2.length) + b2
    b1.zip(b2).map { |a, b| a ^ b }.pack("C*")
  end

  def bisect
    n = self.size
    l = n / 2
    [self[0...l], self[l...n]]
  end

  def zero_pad(length)
    str = self
    str.insert(0, '0') while str.length < length
    str
  end
end
