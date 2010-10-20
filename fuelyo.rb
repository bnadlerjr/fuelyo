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

get '/panel' do
  erb :panel
end

get '/records' do
  user = User.get(session['user_id'])
  @averages = user.fuel_history
  @records = user.fuel_records
  erb :records
end

# TODO: This route should be '/records' to be consistent
post '/incoming' do
  content_type 'text/plain'
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

get '/env' do
  ENV.inspect
end

# TODO: Move inline templates to separate files.
# TODO: Create a layout file.
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

@@ records
<html>
  <head></head>
  <body>
    <h1>Fuelyo</h1>
    <div><%= @averages.join(',') %></div>
    <table>
      <thead>
        <tr>
          <th>Date / Time</th>
          <th>Odometer</th>
          <th>Price</th>
          <th>Gallons</th>
          <th>MPG</th>
        </tr>
      </thead>
      <tbody>
        <% @records.each do |r| %>
          <tr>
            <td><%= r.created_at.strftime("%Y-%m-%d at %I:%M%p") %></td>
            <td><%= r.odometer %></td>
            <td><%= r.price %></td>
            <td><%= r.gallons %></td>
            <td><%= sprintf('%.2f', r.miles_per_gallon) %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </body>
</html>
