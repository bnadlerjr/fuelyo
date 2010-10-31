require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'datamapper'
require 'omniauth'
require 'lib/core-ext/array'
require 'lib/fuel_record'
require 'lib/user'

configure :development, :test do
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

post '/incoming' do
  content_type 'text/plain'
  redirect "/subscription_update" if params['event'] == 'SUBSCRIPTION_UPDATE'

  @r = FuelRecord.new_from_sms(params)
  if @r.save
    erb :new_record
  else
    @r.errors.each { |k,v| v }.join(';')
  end
end

get '/subscription_update' do
  content_type 'text/plain'
  erb :subscription_update
end

get '/auth/:name/callback' do
  auth = request.env['omniauth.auth']
  user = User.find_or_create_by_auth_info(auth)
  session['user_id'] = user.id
  redirect "/records"
end
