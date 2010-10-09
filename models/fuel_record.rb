require 'rubygems'
require 'dm-core'

class FuelRecord
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :odometer, Integer
  property :price, Float
  property :gallons, Float
  property :miles_per_gallon, Float
  property :created_at, DateTime, :default => lambda { |r,p| p = Time.now }

  def self.new_from_sms(sms)
    # TODO : Scope fuel record creation to user_id
    user_id = sms['uid'].gsub(/(\[|\])/, '')
    odometer, price, gallons = sms['body'].split(' ')
    miles_per_gallon = odometer.to_i / gallons.to_f

    FuelRecord.new(
      :user_id          => user_id,
      :odometer         => odometer,
      :price            => price,
      :gallons          => gallons,
      :miles_per_gallon => miles_per_gallon
    )
  end
end
