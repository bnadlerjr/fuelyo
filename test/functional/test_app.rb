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
        "uid"        => "[#{@user.id}]",
        "sms_prefix" => "fuelyo",
        "event"      => "MO",
        "min"        => "test:2137",
        "short_code" => "test:48147"
    }

  end

  def test_can_get_index
    get '/'
    assert last_response.ok?
  end

  def test_can_get_records
    user = User.new
    User.stubs(:get).returns(user)
    user.expects(:fuel_history).returns(Array.new)
    user.expects(:fuel_records).returns(Array.new)

    get '/records', :env => { :session => {:user_id => 1} }
    assert last_response.ok?
  end

  def test_incoming_subscription_update
    post '/incoming', { 'event' => 'SUBSCRIPTION_UPDATE' }
    follow_redirect!

    assert last_response.body.include?('Thanks for signing up to fuelyo')
    assert_content_type 'text/plain;charset=utf-8'
  end

  def test_incoming_first_fuel_record
    post '/incoming', @sms    
    assert last_response.body.include?("You've saved your first fuel record")
    assert_content_type 'text/plain;charset=utf-8'
  end

  def test_incoming_existing_fuel_record
    Factory.create(:fuel_record)
    post '/incoming', @sms
    assert last_response.body.include?('Current MPG is 3.33')
    assert_content_type 'text/plain;charset=utf-8'
  end

  def test_incoming_fuel_record_error
    Factory.create(:fuel_record)
    @sms['body'] = '5 0.99 10'
    post '/incoming', @sms
    assert last_response.body.include?('mis-typed your odometer reading')
    assert_content_type 'text/plain;charset=utf-8'
  end

  private

  def assert_content_type(content_type)
    assert_equal content_type, last_response.headers['Content-Type']
  end
end
