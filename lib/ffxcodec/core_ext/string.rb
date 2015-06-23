class String
  # XOR operation on String
  #
  # @param [String] other string to XOR with
  # @raises [ArgumentError] if other string isn't the same length
  # @return [String] result of XOR operation
  # rubocop:disable AbcSize
  def ^(other)
    # rubocop:disable RedundantSelf, SignalException
    b1 = self.unpack("C*")
    b2 = other.unpack("C*")
    raise ArgumentError, "Strings must be the same length" unless b1.size == b2.size
    longest = [b1.length, b2.length].max
    b1 = [0] * (longest - b1.length) + b1
    b2 = [0] * (longest - b2.length) + b2
    b1.zip(b2).map { |a, b| a ^ b }.pack("C*")
  end

  # Split down the middle into two parts (right-biased)
  #
  # @return [Array<String>] the original string split into two. If length was
  #   odd, then the second string will have an extra character.
  def bisect
    n = self.size
    l = n / 2
    [self[0...l], self[l...n]]
  end

  # Prepend zeroes until string is of the given length
  #
  # @note if string was already longer than the given length, no action taken
  #
  # @param [Integer] length we want the resulting string to be
  # @return [String] prepended with '0's until the given length is reached
  def prepad_zeros(length)
    str = self
    str.insert(0, '0') while str.length < length
    str
  end
end
