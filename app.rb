require 'sinatra'
require 'json'
require 'dotenv/load'
require 'pry'
require 'github_api'

post '/payload' do
  content_type :json
  payload = JSON.parse(request.body.read)

  pull_request = payload['pull_request']
  if payload['action'] == 'closed'
    contents = Github::Client::Repos::Contents.new(login: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'])
    file = contents.find(ENV['GITHUB_ORGANIZATION'], ENV['GITHUB_REPO'], 'CHANGELOG.md')
    new_content = "#{pull_request['title']} ##{pull_request['number']}.\r\n#{file.content}"
    binding.pry
    contents.update('conversation', 'tc-ops',
                    path: 'CHANGELOG.md',
                    message: 'Update CHANGELOG',
                    content: new_content,
                    sha: file.sha)
  end
end
