require 'minitest_helper'

class TestFFXCodec < Minitest::Test
  def encoder(lhs, rhs)
    FFXCodec.new(lhs, rhs)
  end

  def test_correct_encode_results
    assert_equal 165828720871684, encoder(40, 24).encode(1234567890, 4)
  end

  def test_correct_decode_results
    assert_equal [1234567890, 4], encoder(40, 24).decode(165828720871684)
  end

  def test_uses_encryption_when_setup
    enc = encoder(40, 24)
    enc.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "9876543210")
    assert_equal 7692035069140451684, enc.encode(797980150281, 5427652)
    assert_equal [797980150281, 5427652], enc.decode(7692035069140451684)
  end

  def test_correct_32_maximums
    assert_equal [16777215, 255], encoder(24, 8).maximums
    assert_equal [65535, 65535], encoder(16, 16).maximums
  end

  def test_correct_64_maximums
    assert_equal [4294967295, 4294967295], encoder(32, 32).maximums
    assert_equal [1125899906842623, 16383], encoder(50, 14).maximums
  end

  def test_stops_using_encryption_after_disabling
    enc = encoder(40, 24)
    enc.setup_encryption("2b7e151628aed2a6abf7158809cf4f3c", "9876543210")
    enc.disable_encryption
    assert_equal 165828720871684, encoder(40, 24).encode(1234567890, 4)
    assert_equal [1234567890, 4], encoder(40, 24).decode(165828720871684)
  end

  def test_shows_correct_size_for_64_bit
    enc = encoder(32, 32)
    assert_equal 8, enc.size
  end

  def test_shows_correct_size_for_32_bit
    enc = encoder(16, 16)
    assert_equal 4, enc.size
  end

  def test_shows_correct_bitlength_for_64_bit
    enc = encoder(32, 32)
    assert_equal 64, enc.bit_length
  end

  def test_shows_correct_bitlength_for_32_bit
    enc = encoder(16, 16)
    assert_equal 32, enc.bit_length
  end
end
