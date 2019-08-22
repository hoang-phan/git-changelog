require 'sinatra'
require 'json'
require 'dotenv/load'
require 'pry'
require 'github_api'

post '/payload' do
  content_type :json
  payload = JSON.parse(request.body.read)
  contents = Github::Client::Repos::Contents.new(login: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'])
  file = contents.find(ENV['GITHUB_ORGANIZATION'], ENV['GITHUB_REPO'], 'CHANGELOG.md')
  binding.pry
  if payload['action'] == 'closed' && payload['merged']
  end
end
