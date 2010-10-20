ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'fuelyo'

def reset_database
  FuelRecord.destroy
  User.destroy
end

class FuelRecordFactory
  def self.create(options={})
    options.merge!({
      :user_id => 1,
      :odometer => 100,
      :price => 0.99,
      :gallons => 12
    })

    raise "FuelRecordFactory creation error." unless FuelRecord.new(options).save
  end

  def self.create_history
    sample_history = [
      {:created_at=>DateTime.parse('31-01-2010T00:00:00'),:odometer=>0,:gallons=>12},
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
    ]

    sample_history.each { |r| FuelRecord.create(r) }
  end
end

class UserFactory
  def self.create(options={})
    options.merge!({
      :zeep_mobile_uid => 1044,
      :name => 'JohnDoe'
    })

    raise "UserFactory creation error." unless User.new(options).save
  end
end
