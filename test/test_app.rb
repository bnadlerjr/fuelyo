require 'test/test_helper'

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root
    get '/'
    assert_equal 'Welcome to Fuelyo!', last_response.body
  end
end
