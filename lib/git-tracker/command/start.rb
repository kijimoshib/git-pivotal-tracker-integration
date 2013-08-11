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

require 'git-tracker/command/base'
require 'git-tracker/command/command'
require 'git-tracker/util/git'
require 'git-tracker/util/story'
require 'git-tracker/util/feature'
require 'pivotal-tracker'

module GitTracker
# The class that encapsulates starting a Pivotal Tracker Story
  class Command::Start < Command::Base

    # Starts a Pivotal Tracker story by doing the following steps:
    # * Create a branch
    # * Start the story on Pivotal Tracker
    #
    # @param [String, nil] filter a filter for selecting the story to start.  This
    #   filter can be either:
    #   * a story id
    #   * a story type (feature, bug, chore)
    #   * a story status(started, finished, unstarted)
    #   * +nil+
    # @return [void]
    def run(options)

      options[:start] = true

      current_story = GitTracker::Util::Story.select_story @current_project, options
      GitTracker::Util::Story.pretty_print current_story

      current_branch_name = development_branch_name current_story
      GitTracker::Util::Git.create_branch current_branch_name

      @configuration.story = current_story
      start_on_tracker current_story

      current_story.notes.create(:text => "Current branch: #{current_branch_name}",
                                 :noted_at => Time.now.strftime('%D %R %Z'))

      GitTracker::Util::Git.add_hook 'commit-msg', File.join(File.dirname(__FILE__), 'commit-msg.rb')

    end

    private

    def development_branch_name(story)
      branch_name = "#{story.story_type.upcase}/#{story.id}_" +
                    ask("Enter branch name (#{story.story_type.upcase}/#{story.id}_<branch-name>): ")
      puts
      branch_name
    end

    def start_on_tracker(story)
      print 'Starting story on Pivotal Tracker... '
      story.update(
          :current_state => 'started',
          :owned_by => @pivotal_user_name
      )
      puts 'OK'
    end
  end
end
