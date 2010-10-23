require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'datamapper'
require 'yaml'
require 'omniauth'
require 'lib/core-ext/array'
require 'models/fuel_record'
require 'models/user'

configure :development do
  DataMapper::setup(:default, 'sqlite::memory:')
  DataMapper.auto_migrate!
end

configure :test do
  DataMapper::setup(:default, 'sqlite::memory:')
  DataMapper.auto_migrate!
end

configure :production do
  DataMapper::setup(:default, ENV['DATABASE_URL'])
  DataMapper.auto_upgrade!
end

DataMapper.finalize

use OmniAuth::Builder do
  provider :twitter, ENV['twitter_consumerkey'], ENV['twitter_consumersecret']
end

enable :sessions

get '/' do
  erb :index
end

get '/records' do
  user = User.get(session['user_id'])
  @averages = user.fuel_history
  @records = user.fuel_records
  erb :records
end

# TODO: This also needs to handle new signups
post '/incoming' do
  content_type 'text/plain'
  if params['event'] == 'SUBSCRIPTION_UPDATE'
    return 'Great! Thanks for signing up to fuelyo. You can start sending updates with the fuelyo keyword, odometer reading, price per gallon, and gallons purchased. They should look like this: fuelyo 12435 1.99 12'
  end
  r = FuelRecord.new_from_sms(params)
  if r.save
    if 0 == r.miles_per_gallon
      "Great! You've saved your first fuel record. The next time you send fuel information we'll be able to calculate your MPG."
    else
      sprintf("Successfully saved fuel record. Current MPG is %.2f.",
        r.miles_per_gallon)
    end
  else
    r.errors.each { |k,v| v }.join(';')
  end
end

get '/auth/:name/callback' do
  auth = request.env['omniauth.auth']
  user = User.find_or_create_by_auth_info(auth)
  session['user_id'] = user.id
  redirect "/records"
end
