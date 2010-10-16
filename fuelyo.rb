require 'bundler'
Bundler.setup

require 'sinatra'
require 'datamapper'
require 'models/fuel_record'

configure :test do
  DataMapper::setup(:default, 'sqlite::memory:')
end

configure :production do
  DataMapper::setup(:default, ENV['DATABASE_URL'])
end

DataMapper.finalize
DataMapper.auto_migrate!

MESSAGES = {
  :first_save => lambda { 
    "Great! You've saved your first fuel record. The next time you send fuel information we'll be able to calculate your MPG." 
  },
  :save => lambda { |mpg|
    sprintf("Successfully saved fuel record. Current MPG is %.2f.", mpg)
  }
}

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
    0 == r.miles_per_gallon ? MESSAGES[:first_save].call : MESSAGES[:save].call(r.miles_per_gallon)
  else
    r.errors.each { |k,v| v }.join(';')
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
