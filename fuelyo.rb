require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'datamapper'
require 'models/fuel_record'

configure :development do
  DataMapper::setup(:default, 'sqlite::memory:')
end

configure :test do
  DataMapper::setup(:default, 'sqlite::memory:')
  DataMapper.auto_migrate!
end

configure :production do
  DataMapper::setup(:default, ENV['DATABASE_URL'])
end

DataMapper.finalize

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
  @averages = FuelRecord.aggregate(:miles_per_gallon.avg, 
    :fields => [Date::strptime(:created_at, '%d/%m/%Y')])
  @records = FuelRecord.all
  erb :records
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
