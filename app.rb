require 'sinatra'
require 'json'
require 'dotenv/load'

post '/payload' do
  content_type :json
  payload = JSON.parse(request.body.read)
  binding.pry
  if payload['action'] == 'closed' && payload['merged']
  end
end
