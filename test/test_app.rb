require 'test/test_helper'

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    reset_database
    UserFactory.create
  end

  def test_root
    get '/'
    assert_equal 'Welcome to Fuelyo!', last_response.body
  end

  def test_incoming_first_fuel_record
    post '/incoming', {
        "body"       => "150 2.99 15",
        "app_id"     => "1094",
        "uid"        => "[1044]",
        "sms_prefix" => "fuelyo",
        "event"      => "MO",
        "min"        => "test:2137",
        "short_code" => "test:48147"
    }
    
    assert_equal "Great! You've saved your first fuel record. The next time you send fuel information we'll be able to calculate your MPG.", last_response.body
  end

  def test_incoming_existing_fuel_record
    FuelRecordFactory.create
    post '/incoming', {
        "body"       => "150 2.99 15",
        "app_id"     => "1094",
        "uid"        => "[1044]",
        "sms_prefix" => "fuelyo",
        "event"      => "MO",
        "min"        => "test:2137",
        "short_code" => "test:48147"
    }

    assert_equal "Successfully saved fuel record. Current MPG is 3.33.", 
                 last_response.body
  end
end
