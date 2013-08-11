require 'git-tracker/util/context'
require 'git-tracker/util/github_api'
require 'pivotal-tracker'

module GitTracker::Util::Feature
  # We are a blank slate.
  instance_methods.each { |m| undef_method(m) unless m =~ /(^__|send|to\?$)/ }
  extend self

  # provides git interrogation methods
  extend GitTracker::Util::Context

  def pull_request args, story

    options = {}

    base_project = local_repo.main_project

    options[:title] = '%7s/%8d_%s' % [story.story_type, story.id, story.name]
    options[:body] = story.description

    root_branch = GitTracker::Util::Git.get_config KEY_ROOT_BRANCH, :branch

    options[:project] = base_project
    options[:base] = args[:base] || root_branch
    options[:head] = args[:head] || current_branch.short_name

    api_client.create_pullrequest(options)
  end

  def api_client
    @api_client ||= begin
      config_file = ENV['HUB_CONFIG'] || '~/.config/hub'
      file_store = GitTracker::Util::GitHubAPI::FileStore.new File.expand_path(config_file)
      file_config = GitTracker::Util::GitHubAPI::Configuration.new file_store

      GitTracker::Util::GitHubAPI.new file_config, :app_url => 'http://hub.github.com/'
    end
  end

  private

  KEY_ROOT_BRANCH = 'root-branch'.freeze
  KEY_ROOT_REMOTE = 'root-remote'.freeze

end
