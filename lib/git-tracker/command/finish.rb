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
require 'git-tracker/util/feature'

module GitTracker
# The class that encapsulates finishing a Pivotal Tracker Story
  class Command::Finish < Command::Base

    # Finishes a Pivotal Tracker story by doing the following steps:
    # * Check that the pending merge will be trivial
    # * Merge the development branch into the root branch
    # * Delete the development branch
    # * Push changes to remote
    #
    # @return [void]
    def run(options)
      current_story = @configuration.story @current_project

      GitTracker::Util::Git.push GitTracker::Util::Git.branch_name if options[:push]

      print 'Creating pull-request on GutHub... '
      pull = GitTracker::Util::Feature.pull_request options, current_story
      puts 'OK'

      if pull
        print 'Add a new comment to current story... '
        comment = "Pull request: #{pull['html_url']}"
        current_story.notes.create(:text => comment, :noted_at => Time.now.strftime('%D %R %Z'))
        puts 'OK'

        finish_on_tracker current_story
        puts comment
      end
    end

    def finish_on_tracker(story)
      print 'Finishing story on Pivotal Tracker... '
      story.update(
          :current_state => 'finished',
          :owned_by => @pivotal_user_name
      )
      puts 'OK'
    end
  end
end
