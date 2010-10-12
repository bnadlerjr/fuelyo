require 'rubygems'
require 'datamapper'
require 'models/fuel_record'

DataMapper::setup(:default, 'sqlite::memory:')

FuelRecord.auto_migrate!

class FuelRecordFactory
  def self.create
    raise "FuelRecordFactory creation error." unless FuelRecord.new(
      :user_id => 1,
      :odometer => 200,
      :price => 0.99,
      :gallons => 12,
      :miles_per_gallon => 0
    ).save
  end
end
