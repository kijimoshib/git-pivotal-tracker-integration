# Git Pivotal Tracker Integration
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

require 'spec_helper'
require 'git-tracker/command/configuration'
require 'git-tracker/command/start'
require 'git-tracker/util/git'
require 'git-tracker/util/story'
require 'pivotal-tracker'

describe GitTracker::Command::Start do

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new

    @project = double('project')
    @story = double('story')

    GitTracker::Util::Git.should_receive(:repository_root)
    GitTracker::Command::Configuration.any_instance.should_receive(:api_token)
    GitTracker::Command::Configuration.any_instance.should_receive(:project_id)
    GitTracker::Command::Configuration.any_instance.should_receive(:pivotal_user_name).and_return('test_owner')
    PivotalTracker::Project.should_receive(:find).and_return(@project)
    @note = PivotalTracker::Note.new
    @start = GitTracker::Command::Start.new
  end

  it 'should run' do
    GitTracker::Util::Story.should_receive(:select_story).and_return(@story)
    GitTracker::Util::Story.should_receive(:pretty_print)
    @start.should_receive(:ask).and_return('development_branch')
    @story.should_receive(:id).twice.and_return(12345678)
    @story.should_receive(:story_type).twice.and_return('FEATURE')
    @story.should_receive(:notes).and_return(@note)
    PivotalTracker::Note.any_instance.should_receive(:create)
    GitTracker::Util::Git.should_receive(:create_branch).with('FEATURE/12345678_development_branch')
    GitTracker::Command::Configuration.any_instance.should_receive(:story=)
    GitTracker::Util::Git.should_receive(:add_hook)

    @story.should_receive(:update).with(
      :current_state => 'started',
      :owned_by => 'test_owner'
    )

    options = {}
    options[:start] = true
    @start.run options
  end
end
