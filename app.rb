require 'sinatra'
require 'json'
require 'github_api'
require 'httparty'

post '/payload' do
  content_type :json
  payload = JSON.parse(request.body.read)
  pull_request = payload['pull_request']
  if payload['action'] == 'closed' && pull_request && pull_request['merged']
    contents = Github::Client::Repos::Contents.new(login: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'])
    file = contents.find(ENV['GITHUB_ORGANIZATION'], ENV['GITHUB_REPO'], 'CHANGELOG.md')
    file_content = HTTParty.get(file.download_url, basic_auth: { username: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'] })
    new_content = "#{pull_request['title']} ##{pull_request['number']}.\r\n#{file_content.to_s}"
    contents.update(ENV['GITHUB_ORGANIZATION'], ENV['GITHUB_REPO'], 'CHANGELOG.md',
                    path: 'CHANGELOG.md',
                    message: 'Update CHANGELOG',
                    content: new_content,
                    sha: file.sha)
    { success: true }.to_json
  end
  { success: false }.to_json
end
