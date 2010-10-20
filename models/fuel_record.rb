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

  belongs_to :user

  def self.new_from_sms(sms)
    user = User.find_by_zeep_mobile_uid(sms['uid'].gsub(/(\[|\])/, ''))
    odometer, price, gallons = sms['body'].split(' ')

    user.fuel_records.new(
      :user_id  => user_id,
      :odometer => odometer,
      :price    => price,
      :gallons  => gallons
    )
  end

  def self.history
    # TODO: I can't find a DB agnostic way of extracting month and year from a
    # datetime. Also can't find anything in dm-aggregates or dm-core to support
    # this. For now, grab all records in date range and group them using Ruby;
    # this will be SLOW but will do until I find a better way.
    history = {}

    # First group all fuel records by date.
    FuelRecord.all.each do |r|
      date = Date.new(r.created_at.year, r.created_at.month, -1)
      history[date] = [] unless history.has_key?(date)
      history[date] << r.miles_per_gallon
    end

    # Calculate average MPG for each date entry and sort by date.
    history.map { |k,v| [k, v.avg] }.sort { |a,b| a.first <=> b.first }
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
