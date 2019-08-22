require 'sinatra'
require 'json'
require 'github_api'
require 'httparty'

post '/payload' do
  content_type :json
  payload = JSON.parse(request.body.read)
  pull_request = payload['pull_request']
  release = payload['release']

  if payload['action'] == 'closed' && pull_request &&
      pull_request['merged'] && pull_request['base']['ref'] == 'master' &&
      pull_request['labels'].none? { |label| label['name'] == 'skip_changelog' }
    update_changelog("* #{pull_request['title']} ##{pull_request['number']}")
    { success: true }.to_json
  elsif payload['action'] == 'published' && release
    update_changelog("# Version #{release['name']} (#{Time.parse(release['created_at']).strftime('%Y-%m-%d')})")
    { success: true }.to_json
  else
    { success: false }.to_json
  end
end

def update_changelog(appended_content)
  contents = Github::Client::Repos::Contents.new(login: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'])
  file = contents.find(ENV['GITHUB_ORGANIZATION'], ENV['GITHUB_REPO'], 'CHANGELOG.md')
  file_content = HTTParty.get(file.download_url, basic_auth: { username: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'] })
  new_content = "#{appended_content}.\r\n#{file_content.to_s}"
  contents.update(ENV['GITHUB_ORGANIZATION'], ENV['GITHUB_REPO'], 'CHANGELOG.md',
                  path: 'CHANGELOG.md',
                  message: 'Update CHANGELOG',
                  content: new_content,
                  sha: file.sha)
end
