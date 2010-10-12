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

  before :save, :calculate_miles_per_gallon

  def self.new_from_sms(sms)
    # TODO : Scope fuel record creation to user_id
    user_id = sms['uid'].gsub(/(\[|\])/, '')
    odometer, price, gallons = sms['body'].split(' ')

    FuelRecord.new(
      :user_id          => user_id,
      :odometer         => odometer,
      :price            => price,
      :gallons          => gallons
    )
  end

  private

  def calculate_miles_per_gallon
    if prev = FuelRecord.first(:order => [ :created_at.desc ])
      self.miles_per_gallon = (prev.odometer - odometer.to_i) / gallons.to_f
    else
      self.miles_per_gallon = 0
    end
  end
end
