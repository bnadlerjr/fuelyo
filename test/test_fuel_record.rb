require "test/unit"
require "test/test_helper"

class TestFuelRecord < Test::Unit::TestCase
  def setup
    sms = {
      "body"       => "100 2.99 15",
      "app_id"     => "1094",
      "uid"        => "[1044]",
      "sms_prefix" => "fuelyo",
      "event"      => "MO",
      "min"        => "test:2137",
      "short_code" => "test:48147"
    }

    @fr = FuelRecord.new_from_sms(sms)
  end

  def test_new_from_sms
    assert_equal 1044, @fr.user_id, 'user_id'
    assert_equal 100, @fr.odometer, 'odometer'
    assert_equal 2.99, @fr.price, 'price'
    assert_equal 15, @fr.gallons, 'gallons'
    assert_equal 6.666666666666667, @fr.miles_per_gallon, 'miles_per_gallon'
  end

  def test_cannot_calculate_mpg_with_only_one_fuel_record
    assert_equal 0, FuelRecord.all.count
  end
end
