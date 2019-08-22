require 'sinatra'
require 'json'

post '/payload' do
  content_type :json
  payload = JSON.parse(request.body.read)
  puts payload.to_json
  payload.to_json
end
