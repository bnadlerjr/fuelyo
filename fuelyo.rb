require 'bundler'
Bundler.setup

require 'sinatra'

get '/' do
  'Welcome to Fuelyo!'
end

get '/panel' do
  erb :panel
end

post '/incoming' do
  content_type 'text/plain'
  'Hello user 1044!' +
  "SMS #{params[:event][:body]}"
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
