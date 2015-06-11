require 'minitest_helper'

class TestEncoder < Minitest::Test
  def encoder(lhs, rhs)
    FFXCodec::Encoder.new(lhs, rhs)
  end

  def test_correct_encoded_result1
    enc = encoder(40, 24)
    assert_equal 20712612157194244, enc.encode(1234567890, 4)
    assert_equal 207126118818126, enc.encode(12345678, 12345678)
    assert_equal 2065667107513, enc.encode(123123, 5941945)
  end

  def test_correct_decoded_result1
    enc = encoder(40, 24)
    assert_equal [1234567890, 4], enc.decode(20712612157194244)
    assert_equal [12345678, 12345678], enc.decode(207126118818126)
    assert_equal [123123, 5941945], enc.decode(2065667107513)
  end

  def test_correct_encoded_result2
    enc = encoder(32, 32)
    assert_equal 5302424889720836, enc.encode(1234567, 4)
    assert_equal 4294967298, enc.encode(1, 2)
    assert_equal 16086812286712480250, enc.encode(3745502859, 232980986)
  end

  def test_correct_decoded_result2
    enc = encoder(32, 32)
    assert_equal [1234567, 4], enc.decode(5302424889720836)
    assert_equal [1, 2], enc.decode(4294967298)
    assert_equal [3745502859, 232980986], enc.decode(16086812286712480250)
  end

  def test_correct_encoded_result3
    enc = encoder(24, 40)
    assert_equal 4116204368438274466, enc.encode(3743666, 70928607650)
    assert_equal 9717243587552383052, enc.encode(8837781, 614314577996)
    assert_equal 1099511627778, enc.encode(1, 2)
  end

  def test_correct_decoded_result3
    enc = encoder(24, 40)
    assert_equal [3743666, 70928607650], enc.decode(4116204368438274466)
    assert_equal [8837781, 614314577996], enc.decode(9717243587552383052)
    assert_equal [1, 2], enc.decode(1099511627778)
  end

  def test_correct_encoded_result4
    enc = encoder(8, 56)
    assert_equal 7153227423786204750, enc.encode(99, 19525614031339086)
    assert_equal 11202716620044058537, enc.encode(155, 33789544165228457)
    assert_equal 17157386009052208939, enc.encode(238, 7678628025360171)
  end

  def test_correct_decoded_result4
    enc = encoder(8, 56)
    assert_equal [99, 19525614031339086], enc.decode(7153227423786204750)
    assert_equal [155, 33789544165228457], enc.decode(11202716620044058537)
    assert_equal [238, 7678628025360171], enc.decode(17157386009052208939)
  end

  def test_correct_encoded_result_at_64_maximums
    assert_equal 18446744073709551615, encoder(32, 32).encode(4294967295, 4294967295)
    assert_equal 18446744073709551615, encoder(40, 24).encode(1099511627775, 16777215)
    assert_equal 18446744073709551615, encoder(1, 63).encode(1, 9223372036854775807)
    assert_equal 18446744073709551615, encoder(63, 1).encode(9223372036854775807, 1)
  end

  def test_correct_decoded_result_at_64_maximums
    assert_equal [4294967295, 4294967295], encoder(32, 32).decode(18446744073709551615)
    assert_equal [1099511627775, 16777215], encoder(40, 24).decode(18446744073709551615)
    assert_equal [1, 9223372036854775807], encoder(1, 63).decode(18446744073709551615)
    assert_equal [9223372036854775807, 1], encoder(63, 1).decode(18446744073709551615)
  end

  def test_correct_encoded_result_at_32_maximums
    assert_equal 4294967295, encoder(16, 16).encode(65535, 65535)
    assert_equal 4294967295, encoder(8, 24).encode(255, 16777215)
    assert_equal 4294967295, encoder(24, 8).encode(16777215, 255)
  end

  def test_correct_decoded_result_at_32_maximums
    assert_equal [65535, 65535], encoder(16, 16).decode(4294967295)
    assert_equal [255, 16777215], encoder(8, 24).decode(4294967295)
    assert_equal [16777215, 255], encoder(24, 8).decode(4294967295)
  end

  def test_raises_argumenterror_when_lhs_input_too_big
    lhs = ('1' * 41).to_i(2)
    assert_raises ArgumentError do
      encoder(40, 24).encode(lhs, 4)
    end
  end

  def test_raises_argumenterror_when_rhs_input_too_big
    rhs = ('1' * 25).to_i(2)
    assert_raises ArgumentError do
      encoder(40, 24).encode(4, rhs)
    end
  end

  def test_raises_argumenterror_when_sum_not_32_or_64
    assert_raises ArgumentError do
      encoder(32, 33)
    end
    assert_raises ArgumentError do
      encoder(17, 16)
    end
  end
end
