require "test/test_helper"

class TestFuelRecord < Test::Unit::TestCase
  def setup
    sms = {
      "body"       => "150 2.99 15",
      "app_id"     => "1094",
      "uid"        => "[1044]",
      "sms_prefix" => "fuelyo",
      "event"      => "MO",
      "min"        => "test:2137",
      "short_code" => "test:48147"
    }

    reset_database

    UserFactory.create
    @fr = FuelRecord.new_from_sms(sms)
  end

  def test_new_from_sms
    FuelRecordFactory.create
    assert @fr.save, "Cannot save fuel record: #{@fr.errors.each { |e| p e }}"

    assert_equal 2, FuelRecord.all.count
    assert_equal 150, @fr.odometer, 'odometer'
    assert_equal 2.99, @fr.price, 'price'
    assert_equal 15, @fr.gallons, 'gallons'
    assert_in_delta 3.33, @fr.miles_per_gallon, 0.01, 'miles_per_gallon'
  end

  def test_cannot_calculate_mpg_without_any_saved_fuel_records
    @fr.save
    assert_equal 0, @fr.miles_per_gallon
  end

  def test_current_odometer_cannot_be_less_than_most_recent_odometer
    FuelRecordFactory.create
    fr = FuelRecord.new(:odometer => 90)
    msg = <<MSG
Oops! You might have mis-typed your odometer reading. Your last odometer reading was 100 and you entered 90 for your current reading.
MSG
    assert !fr.save
    assert_equal msg, fr.errors[:odometer][0]
  end

  def test_history
    FuelRecordFactory.create_history
    history = FuelRecord.history

    expected = [
      [Date.parse('31-01-2010'), 0.415],
      [Date.parse('28-02-2010'), 0.830],
      [Date.parse('31-03-2010'), 0.830],
      [Date.parse('30-04-2010'), 0.830],
      [Date.parse('31-05-2010'), 0.830],
      [Date.parse('30-06-2010'), 0.830],
      [Date.parse('31-07-2010'), 0.830],
      [Date.parse('31-08-2010'), 0.830],
      [Date.parse('30-09-2010'), 0.830],
      [Date.parse('31-10-2010'), 0.830]
    ].each_with_index do |e, i|
      assert_history_record_equal e, history[i]
    end
  end

  private

  def assert_history_record_equal(expected, actual, tolerance=0.01)
    assert_equal expected[0], actual[0]
    assert_in_delta expected[1], actual[1], tolerance, 
      "#{expected[0]} - #{actual[0]}"
  end
end

# 0
# 0.83
# 0.415
#
# 0.83
# 0.83
#
#
# 0.83
#
# 0.83
# 0.83
# 0.83
#
# 0.83
#
# 0.83
# 0.83
# 0.83
#
# 0.83
#
# 0.83
# 0.83
# 0.83
#
# 0.83
# 0.83
# 0.83
#
# 0.83
