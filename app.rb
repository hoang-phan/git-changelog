require 'sinatra'
require 'json'

post '/payload' do
  content_type :json
  payload = JSON.parse(request.body.read)
  payload.to_json
end
