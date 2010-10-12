require 'rubygems'
require 'datamapper'
require 'models/fuel_record'

DataMapper::setup(:default, 'sqlite::memory:')

FuelRecord.auto_migrate!

class FuelRecordFactory
  def self.create(options={})
    options.merge!({
      :user_id => 1,
      :odometer => 100,
      :price => 0.99,
      :gallons => 12,
      :miles_per_gallon => 0
    })

    raise "FuelRecordFactory creation error." unless FuelRecord.new(options).save
  end
end
