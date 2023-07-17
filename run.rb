require_relative 'lib/pull_request_description_service'

service = PullRequestDescriptionService::Generator.new(
  ENV['REPO'],
  ENV['PR_NUMBER'],
  ENV['GITHUB_REPOSITORY']
)
service.run
