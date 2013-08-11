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
require 'git-tracker/util/git'
require 'git-tracker/util/shell'

describe GitTracker::Util::Git do

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  it 'should return the current branch name' do
    GitTracker::Util::Shell.should_receive(:exec).with('git branch').and_return("   master\n * dev_branch")

    current_branch = GitTracker::Util::Git.branch_name

    expect(current_branch).to eq('dev_branch')
  end

  it 'should return the repository root' do
    Dir.mktmpdir do |root|
      child_directory = File.expand_path 'child', root
      Dir.mkdir child_directory

      git_directory = File.expand_path '.git', root
      Dir.mkdir git_directory

      Dir.should_receive(:pwd).and_return(child_directory)

      repository_root = GitTracker::Util::Git.repository_root

      expect(repository_root).to eq(root)
    end
  end

  it 'should raise an error there is no repository root' do
    Dir.mktmpdir do |root|
      child_directory = File.expand_path 'child', root
      Dir.mkdir child_directory

      Dir.should_receive(:pwd).and_return(child_directory)

      expect { GitTracker::Util::Git.repository_root }.to raise_error
    end
  end

  it 'should get configuration when :branch scope is specified' do
    GitTracker::Util::Git.should_receive(:branch_name).and_return('test_branch_name')
    GitTracker::Util::Shell.should_receive(:exec).with('git config branch.test_branch_name.test_key', false).and_return('test_value')

    value = GitTracker::Util::Git.get_config 'test_key', :branch

    expect(value).to eq('test_value')
  end

  it 'should get configuration when :inherited scope is specified' do
    GitTracker::Util::Shell.should_receive(:exec).with('git config test_key', false).and_return('test_value')

    value = GitTracker::Util::Git.get_config 'test_key', :inherited

    expect(value).to eq('test_value')
  end

  it 'should raise an error when an unknown scope is specified (get)' do
    expect { GitTracker::Util::Git.get_config 'test_key', :unknown }.to raise_error
  end

  it 'should set configuration when :branch scope is specified' do
    GitTracker::Util::Git.should_receive(:branch_name).and_return('test_branch_name')
    GitTracker::Util::Shell.should_receive(:exec).with('git config --local branch.test_branch_name.test_key test_value')

    GitTracker::Util::Git.set_config 'test_key', 'test_value', :branch
  end

  it 'should set configuration when :global scope is specified' do
    GitTracker::Util::Shell.should_receive(:exec).with('git config --global test_key test_value')

    GitTracker::Util::Git.set_config 'test_key', 'test_value', :global
  end

  it 'should set configuration when :local scope is specified' do
    GitTracker::Util::Shell.should_receive(:exec).with('git config --local test_key test_value')

    GitTracker::Util::Git.set_config 'test_key', 'test_value', :local
  end

  it 'should raise an error when an unknown scope is specified (set)' do
    expect { GitTracker::Util::Git.set_config 'test_key', 'test_value', :unknown }.to raise_error
  end

  it 'should create a branch and set the root_branch and root_remote properties on it' do
    GitTracker::Util::Git.should_receive(:branch_name).and_return('master')
    GitTracker::Util::Git.should_receive(:get_config).with('remote', :branch).and_return('origin')
    GitTracker::Util::Shell.should_receive(:exec).with('git pull --quiet --ff-only')
    GitTracker::Util::Shell.should_receive(:exec).and_return('git checkout --quiet -b dev_branch')
    GitTracker::Util::Git.should_receive(:set_config).with('root-branch', 'master', :branch)
    GitTracker::Util::Git.should_receive(:set_config).with('root-remote', 'origin', :branch)

    GitTracker::Util::Git.create_branch 'dev_branch'
  end

  it 'should not add a hook if it already exists' do
    Dir.mktmpdir do |root|
      GitTracker::Util::Git.should_receive(:repository_root).and_return(root)
      hook = "#{root}/.git/hooks/prepare-commit-msg"
      File.should_receive(:exist?).with(hook).and_return(true)

      GitTracker::Util::Git.add_hook 'prepare-commit-msg', __FILE__

      File.should_receive(:exist?).and_call_original
      expect(File.exist?(hook)).to be_false
    end
  end

  it 'should add a hook if it does not exist' do
    Dir.mktmpdir do |root|
      GitTracker::Util::Git.should_receive(:repository_root).and_return(root)
      hook = "#{root}/.git/hooks/prepare-commit-msg"
      File.should_receive(:exist?).with(hook).and_return(false)

      GitTracker::Util::Git.add_hook 'prepare-commit-msg', __FILE__

      File.should_receive(:exist?).and_call_original
      expect(File.exist?(hook)).to be_true
    end
  end

  it 'should add a hook if it already exists and overwrite is true' do
    Dir.mktmpdir do |root|
      GitTracker::Util::Git.should_receive(:repository_root).and_return(root)
      hook = "#{root}/.git/hooks/prepare-commit-msg"

      GitTracker::Util::Git.add_hook 'prepare-commit-msg', __FILE__, true

      File.should_receive(:exist?).and_call_original
      expect(File.exist?(hook)).to be_true
    end
  end

  it 'should push changes without refs' do
    GitTracker::Util::Git.should_receive(:get_config).with('root-remote', :branch).and_return('origin')
    GitTracker::Util::Shell.should_receive(:exec).with('git push --quiet origin ')

    GitTracker::Util::Git.push
  end

  it 'should push changes with refs' do
    GitTracker::Util::Git.should_receive(:get_config).with('root-remote', :branch).and_return('origin')
    GitTracker::Util::Shell.should_receive(:exec).with('git push --quiet origin foo bar')

    GitTracker::Util::Git.push 'foo', 'bar'
  end

  it 'should create a commit' do
    story = PivotalTracker::Story.new(:id => 123456789)
    GitTracker::Util::Shell.should_receive(:exec).with("git commit --quiet --all --allow-empty --message \"test_message\n\n[#123456789]\"")

    GitTracker::Util::Git.create_commit 'test_message', story
  end
end
