require "test/test_helper"

class TestFuelRecord < Test::Unit::TestCase
  def setup
    reset_database

    @user = Factory.create(:user)

    sms = {
      "body"       => "150 2.99 15",
      "app_id"     => "1094",
      "uid"        => "#{@user.id}",
      "sms_prefix" => "fuelyo",
      "event"      => "MO",
      "min"        => "test:2137",
      "short_code" => "test:48147"
    }

    @fr = FuelRecord.new_from_sms(sms)
  end

  def test_new_from_sms
    Factory.create(:fuel_record)
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
    Factory.create(:fuel_record)
    fr = FuelRecord.new(:odometer => 90)
    msg = <<MSG
Oops! You might have mis-typed your odometer reading. Your last odometer reading was 100 and you entered 90 for your current reading.
MSG
    assert !fr.save
    assert_equal msg, fr.errors[:odometer][0]
  end

  def test_history
    [{:created_at=>DateTime.parse('31-01-2010T00:00:00'),:odometer=>0,:gallons=>12},
      {:created_at=>DateTime.parse('31-01-2010T00:00:01'),:odometer=>10,:gallons=>12},
      {:created_at=>DateTime.parse('28-02-2010T00:00:00'),:odometer=>20,:gallons=>12},
      {:created_at=>DateTime.parse('28-02-2010T00:00:01'),:odometer=>30,:gallons=>12},
      {:created_at=>DateTime.parse('31-03-2010T00:00:00'),:odometer=>40,:gallons=>12},
      {:created_at=>DateTime.parse('30-04-2010T00:00:00'),:odometer=>50,:gallons=>12},
      {:created_at=>DateTime.parse('30-04-2010T00:00:01'),:odometer=>60,:gallons=>12},
      {:created_at=>DateTime.parse('30-04-2010T00:00:02'),:odometer=>70,:gallons=>12},
      {:created_at=>DateTime.parse('31-05-2010T00:00:00'),:odometer=>80,:gallons=>12},
      {:created_at=>DateTime.parse('30-06-2010T00:00:00'),:odometer=>90,:gallons=>12},
      {:created_at=>DateTime.parse('30-06-2010T00:00:01'),:odometer=>100,:gallons=>12},
      {:created_at=>DateTime.parse('30-06-2010T00:00:02'),:odometer=>110,:gallons=>12},
      {:created_at=>DateTime.parse('31-07-2010T00:00:00'),:odometer=>120,:gallons=>12},
      {:created_at=>DateTime.parse('31-08-2010T00:00:00'),:odometer=>130,:gallons=>12},
      {:created_at=>DateTime.parse('31-08-2010T00:00:01'),:odometer=>140,:gallons=>12},
      {:created_at=>DateTime.parse('31-08-2010T00:00:02'),:odometer=>150,:gallons=>12},
      {:created_at=>DateTime.parse('30-09-2010T00:00:00'),:odometer=>160,:gallons=>12},
      {:created_at=>DateTime.parse('30-09-2010T00:00:01'),:odometer=>170,:gallons=>12},
      {:created_at=>DateTime.parse('30-09-2010T00:00:02'),:odometer=>180,:gallons=>12},
      {:created_at=>DateTime.parse('31-10-2010T00:00:00'),:odometer=>190,:gallons=>12}
    ].each do |r|
      # TODO: Factory.create doesn't work here. For some reason the before save
      # callback is not executed. Bug in factory_girl? Or maybe it has to do
      # with the fact that I'm explicitly setting the user_id? Need to investigate.
      f = Factory.build(:fuel_record, :user_id => @user.id, 
        :created_at => r[:created_at], :odometer => r[:odometer], :gallons => r[:gallons])
      f.save
    end

    history = FuelRecord.history(@user.id)

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
