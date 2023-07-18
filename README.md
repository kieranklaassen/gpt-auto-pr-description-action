# **Change PR Description GitHub Action**

This action is designed to automatically update or modify the description of a pull request. It uses OpenAI's GPT model to generate the description content based on the pull request content or a given template. This is especially useful when you want to maintain a standardized format across all pull request descriptions in a repository.

## **Inputs**

The action takes several inputs:

- **`github-token`**: Your GitHub token. This is required to interact with the GitHub API and is always required.
- **`pr-number`**: The number of the pull request that the description should be updated for. This is also always required.
- **`openai-token`**: Your OpenAI token. This is used to generate the description using OpenAI's models and is always required. Make sure to store this token as a GitHub secret and pass it as an input to your workflow.
- **`pull-request-template`**: An optional path to a template file that should be used for generating the PR description. If not provided, the description will be generated based on the PR's content.
- **`trigger-word`**: An optional trigger word that will trigger the action when found in the PR's description. If not provided, the default is "auto", which means the action will run automatically whenever a PR is opened.
- **`openai-model`**: An optional parameter to specify the OpenAI model to be used for generating the PR description. If not provided, the default model is **`gpt-3.5-turbo-16k`**.
- **`skip-if-author-is`**: An optional parameter to specify a list of authors (comma separated) for which the action should not run. By default, this is empty, meaning the action will run for all authors.

## **Usage**

To use this action, you should add it to your GitHub workflow. Here is an example workflow that uses this action:

```yaml
name: Draft PR Description
on:
  pull_request:
    types: [opened]

jobs:
  change-description:
    runs-on: ubuntu-latest
    steps:
      - name: Add Draft PR description
        uses: kieranklaassen/gpt-auto-pr-description-action@main
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          pr-number: ${{ github.event.pull_request.number }}
          openai-token: ${{ secrets.OPENAI_TOKEN }}
```

In this example, the action is triggered whenever a pull request is opened. It uses the **`github-token`**, **`pr-number`**, and **`openai-token`** inputs to interact with the GitHub API and generate the PR description. The OpenAI token is stored as a secret to keep it secure.

## **Dependencies**

This action depends on:

- Ruby and the ruby/setup-ruby action to set up a Ruby environment.
- The actions/checkout action to check out the repository.
- Your OpenAI token to access the OpenAI API. Make sure to store this token as a GitHub secret and pass it as an input to your workflow.

## **Contributing**

Contributions to improve this action are welcomed. Feel free to open an issue or pull request in this repository.

## **License**

This action is released under the MIT License.
