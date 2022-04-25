# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'

require 'choria/colt/version'

RuboCop::RakeTask.new

require 'github_changelog_generator/task'

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = 'opus-codium'
  config.project = 'choria-colt'
  config.since_tag = 'v0.1.0'
  config.future_release = "v#{Choria::Colt::VERSION}"
end

task default: :rubocop
