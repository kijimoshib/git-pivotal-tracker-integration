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
require 'git-tracker/command/finish'
require 'git-tracker/util/git'
require 'pivotal-tracker'

describe GitTracker::Command::Finish do

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new

    @project = double('project')
    GitTracker::Command::Configuration.any_instance.should_receive(:api_token)
    GitTracker::Command::Configuration.any_instance.should_receive(:project_id)
    GitTracker::Command::Configuration.any_instance.should_receive(:pivotal_user_name)
    PivotalTracker::Project.should_receive(:find).and_return(@project)
    @finish = GitTracker::Command::Finish.new
  end

  it 'should run' do
    GitTracker::Util::Feature.should_receive(:pull_request)
    GitTracker::Command::Configuration.any_instance.should_receive(:story)
    GitTracker::Util::Git.should_receive(:branch_name).and_return('master')
    GitTracker::Util::Git.should_receive(:push).with('master')

    options ={}
    options[:push] = true
    @finish.run options
  end
end
