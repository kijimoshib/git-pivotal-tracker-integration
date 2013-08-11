# Git Tracker
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'git-tracker/command/command'
require 'git-tracker/command/configuration'
require 'git-tracker/util/git'
require 'pivotal-tracker'

# An abstract base class for all commands
# @abstract Subclass and override {#run} to implement command functionality
class GitTracker::Command::Base

  # Common initialization functionality for all command classes.  This
  # enforces that:
  # * the command is being run within a valid Git repository
  # * the user has specified their Pivotal Tracker API token
  # * all communication with Pivotal Tracker will be protected with SSL
  # * the user has configured the project id for this repository
  def initialize
    @repository_root = GitTracker::Util::Git.repository_root
    @configuration = GitTracker::Command::Configuration.new

    PivotalTracker::Client.token = @configuration.api_token
    PivotalTracker::Client.use_ssl = true

    @current_project = PivotalTracker::Project.find @configuration.project_id
    @pivotal_user_name = @configuration.pivotal_user_name @current_project
  end

  # The main entry point to the command's execution
  # @abstract Override this method to implement command functionality
  def run
    raise NotImplementedError
  end

end
