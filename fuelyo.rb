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

helpers do
  def current_user
    session['user_id'] ? User.get(session['user_id']) : nil
  end
end

get '/' do
  erb :index
end

get '/about' do
  erb :about
end

get '/records' do
  user = User.get(session['user_id'])
  @averages, @records = user.fuel_history, user.fuel_records 
  erb :records
end

post '/incoming' do
  content_type 'text/plain'
  redirect "/subscription_update" if 'SUBSCRIPTION_UPDATE' == params['event']

  @r = FuelRecord.new_from_sms(params)
  @r.save ? (erb :new_record) : (@r.errors.each { |k,v| v }.join(';'))
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
