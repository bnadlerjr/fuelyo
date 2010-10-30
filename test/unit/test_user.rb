require 'test/test_helper'

class TestUser < Test::Unit::TestCase
  def setup
    @auth = {
      'uid' => 1,
      'provider' => 'twitter',
      'user_info' => { 'name' => 'John Doe' }
    }

    @user = Factory.build(:user,
      :provider => 'twitter', :auth_provider_uid => 1, :name => 'John Doe')
  end

  def test_create_by_auth_info
    User.any_instance.expects(:save).returns(true)
    result = User.find_or_create_by_auth_info(@auth)
    assert_equal @user, result
  end

  def test_find_by_auth_info
    User.expects(:first).with(:auth_provider_uid => @auth['uid'])
    result = User.find_or_create_by_auth_info(@auth)
    assert_equal @user.provider, result.provider
    assert_equal @user.auth_provider_uid, result.auth_provider_uid
    assert_equal @user.name, result.name
  end

  def test_fuel_record_history
    assert_not_nil Factory.create(:user).fuel_history
  end
end
