require 'octokit'
require 'openai'
require 'open3'
require 'fileutils'
require 'find'

# Debug output: show the current working directory
puts "Current directory: #{Dir.pwd}"

# Instantiate Octokit client
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_TOKEN'])

# Look for the pull_request_template.md in all directories (including hidden ones) and subdirectories
template_files = Dir.glob("**/{,.[^.]}*/pull_request_template.md", File::FNM_DOTMATCH)

# Debug output: show found files
puts "Found files: #{template_files}"

# Exclude paths that include 'node_modules'
template_files.reject! { |path| path.include?('node_modules') }

# Debug output: show found files after excluding 'node_modules'
puts "Found files after excluding 'node_modules': #{template_files}"

template_file = template_files.first

# If the pull_request_template.md file is found, read its contents
template_markdown = if template_file
  File.read(template_file)
else
  "Give a description of the changes in a list of this PR."
end

def get_commits_from_pull_request(client, repo, pr_number)
  puts "Getting commits from pull request"
  commits = client.pull_request_commits(repo, pr_number)
  puts "Commits: #{commits}"
  commits.map { |commit| commit[:commit][:message] }
end

def get_diff_from_comments(client, repo, pr_number)
  puts "Getting diff from comments"
  comments = client.pull_request_comments(repo, pr_number)
  puts "Comments: #{comments}"
  comments.map { |comment| comment[:diff_hunk] }.join("\n")
end


def generate_prompt(commits, git_diff, template_markdown)
  puts "Generating prompt from commits and diff"
  puts "Commits: #{commits}"
  puts "Diff: #{git_diff}"
  puts "Template: #{template_markdown}"

  commit_list = commits.map { |commit| "- #{commit}" }.join("\n")
  <<~PROMPT
    I have a feature with the following commits:

    #{commit_list}

    I have the following diff:

    #{git_diff}

    Write a Pull Request description for this diff in this format:

    ```md
    #{template_markdown}
    ```

    Give me a markdown file and remove sections that are not relevant to the diff.
  PROMPT
end

repo = ENV['REPO']
base_branch = ENV['BASE_BRANCH']
head_branch = ENV['HEAD_BRANCH']

prompt = generate_prompt(
  get_commits_from_pull_request(client, repo, ENV['PR_NUMBER']),
  get_diff_from_comments(client, repo, ENV['PR_NUMBER']),
  template_markdown
)

puts "Prompt: #{prompt}"

response = openai_client.chat(
  parameters: {
    model: "gpt-3.5-turbo-16k", # Required.
    messages: [
      {role: "system", content: "You are a helpful assistant that's going to help write a PR description."},
      {role: "user", content: prompt}
    ],
    temperature: 0.7,
    max_tokens: 1600,
  }
)

puts "Response: #{response}"

completion = response['choices'].first['message']['content'].strip

# Update the pull request
client.update_pull_request(ENV['GITHUB_REPOSITORY'], ENV['PR_NUMBER'], body: completion)

puts "PR description updated on GitHub!"
