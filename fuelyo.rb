require 'bundler'
Bundler.setup

require 'sinatra'
require 'datamapper'

configure :production do
  DataMapper::setup(:default, ENV['DATABASE_URL'])
end

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
    odometer, price, gallons = sms[:body].split(' ')

    r = FuelRecord.new(
      :user_id  => sms[:uid],
      :odometer => odometer,
      :price    => price,
      :gallons  => gallons)

    r
  end

  private

  def calculate_miles_per_gallon
    miles_per_gallon = odometer / gallons
  end
end

FuelRecord.auto_migrate!

get '/' do
  'Welcome to Fuelyo!'
end

get '/panel' do
  erb :panel
end

get '/records' do
  FuelRecord.all
end

post '/incoming' do
  content_type 'text/plain'
  r = FuelRecord.new_from_sms(params)
  if r.save
    "Successfully saved fuel record. Current MPG is #{r.miles_per_gallon}."
  else
    "There was a problem trying to save your fuel record."
  end
end

get '/env' do
  ENV.inspect
end

enable :inline_templates

__END__

@@ panel
<iframe 
  style="width: 100%; height: 300px; border: none;" 
  frameborder="0" allowtransparency="0"
  id="zeep_mobile_settings_panel" 
  src="https://www.zeepmobile.com/subscription/settings?api_key=5f02d2d6-97e8-4316-83b6-f5ee69b6af26&user_id=[1044]"
>
</iframe>  
