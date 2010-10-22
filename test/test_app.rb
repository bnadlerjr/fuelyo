require 'test/test_helper'

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    reset_database
    @user = Factory.create(:user)
    @sms = {
        "body"       => "150 2.99 15",
        "app_id"     => "1094",
        "uid"        => "#{@user.id}",
        "sms_prefix" => "fuelyo",
        "event"      => "MO",
        "min"        => "test:2137",
        "short_code" => "test:48147"
    }

  end

  def test_incoming_first_fuel_record
    post '/incoming', @sms    

    assert_equal "Great! You've saved your first fuel record. The next time you send fuel information we'll be able to calculate your MPG.", last_response.body
  end

  def test_incoming_existing_fuel_record
    Factory.create(:fuel_record)
    post '/incoming', @sms

    assert_equal "Successfully saved fuel record. Current MPG is 3.33.", 
                 last_response.body
  end
end
