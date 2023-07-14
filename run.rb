require 'octokit'
require 'find'

# Instantiate Octokit client
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])

# Look for the pull_request_template.md in the ./app directory
template_file = nil
Find.find('./app') do |path|
  if File.basename(path) == 'pull_request_template.md' && !File.directory?(path)
    template_file = path
    break
  end
end

# If the pull_request_template.md file is found, read its contents
new_description = if template_file
  File.read(template_file)
else
  "New PR"
end

# Update the pull request
client.update_pull_request(ENV['GITHUB_REPOSITORY'], ENV['PR_NUMBER'], body: new_description)
