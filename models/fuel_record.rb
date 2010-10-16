class FuelRecord
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :odometer, Integer
  property :price, Float
  property :gallons, Float
  property :miles_per_gallon, Float
  property :created_at, DateTime, :default => lambda { |r,p| p = Time.now }

  validates_with_method :odometer, :method => :check_previous_odometer

  before :save, :calculate_miles_per_gallon

  def self.new_from_sms(sms)
    # TODO : Scope fuel record creation to user_id
    user_id = sms['uid'].gsub(/(\[|\])/, '')
    odometer, price, gallons = sms['body'].split(' ')

    FuelRecord.new(
      :user_id  => user_id,
      :odometer => odometer,
      :price    => price,
      :gallons  => gallons
    )
  end

  private

  def calculate_miles_per_gallon
    self.miles_per_gallon = 0 and return unless previous_record

    self.miles_per_gallon =
      (odometer.to_i - previous_record.odometer) / gallons.to_f
  end

  def check_previous_odometer
    return true unless previous_record # no previous reading to check

    msg = <<MSG
Oops! You might have mis-typed your odometer reading. Your last odometer reading was #{previous_record.odometer} and you entered #{odometer} for your current reading.
MSG

    return odometer < previous_record.odometer ? [false, msg] : true
  end

  def previous_record
    FuelRecord.first(:order => [ :created_at.desc ])
  end
end
