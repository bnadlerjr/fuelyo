require 'test/test_helper'

class TestArrayExtensions < Test::Unit::TestCase
  def test_sum
    assert_equal 10, [1, 5, 4].sum
  end

  def test_avg
    assert_equal 50, [0, 50, 100].avg
  end
end
