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

require 'git-tracker/util/util'
require 'highline/import'
require 'pivotal-tracker'

# Utilities for dealing with +PivotalTracker::Story+s
class GitTracker::Util::Story

  # Print a human readable version of a story.  This pretty prints the title,
  # description, and notes for the story.
  #
  # @param [PivotalTracker::Story] story the story to pretty print
  # @return [void]
  def self.pretty_print(story)
    print_label LABEL_TITLE
    print_value story.name

    description = story.description
    if !description.nil? && !description.empty?
      print_label 'Description'
      print_value description
    end

    puts
    puts 'Comments:'

    PivotalTracker::Note.all(story).sort_by { |note| note.noted_at }.each_with_index do |note, index|
      print_label "[#{note.noted_at.strftime('%D %R %Z')}]"
      print_value " <#{note.author}> #{note.text}"
    end

    puts
  end

  # Selects a Pivotal Tracker story by doing the following steps:
  #
  # @param [PivotalTracker::Project] project the project to select stories from
  # @param [String, nil] filter a filter for selecting the story to start.  This
  #   filter can be either:
  #   * a story id: selects the story represented by the id
  #   * a story type (feature, bug, chore): offers the user a selection of stories of the given type
  #   * +nil+: offers the user a selection of stories of all types
  # @param [Fixnum] limit The number maximum number of stories the user can choose from
  # @return [PivotalTracker::Story] The Pivotal Tracker story selected by the user
  def self.select_story(project, options)
    if options[:story_id] =~ /[[:digit:]]/
      story = project.stories.find options[:story_id].to_i
    else
      story = find_story project, options
    end

    story
  end

  private

  CANDIDATE_STATES = %w(rejected unstarted unscheduled).freeze

  LABEL_DESCRIPTION = 'Description'.freeze

  LABEL_TITLE = 'Title'.freeze

  LABEL_WIDTH = (LABEL_DESCRIPTION.length + 2).freeze

  CONTENT_WIDTH = (HighLine.new.output_cols - LABEL_WIDTH).freeze

  def self.print_label(label)
    print "%#{LABEL_WIDTH}s" % ["#{label}: "]
  end

  def self.print_value(value)
    if value.nil? || value.empty?
      puts ''
    else
      value.scan(/\S.{0,#{CONTENT_WIDTH - 2}}\S(?=\s|$)|\S+/).each_with_index do |line, index|
        if index == 0
          puts line
        else
          puts "%#{LABEL_WIDTH}s%s" % ['', line]
        end
      end
    end
  end

  def self.find_story(project, options)
    filter = {}

    filter[:story_type] = options[:story_type] if options[:story_type]
    filter[:current_state] = CANDIDATE_STATES unless options[:all]

    candidates = project.stories.all filter

    if candidates.length == 1
      story = candidates[0]
      puts 'We have only one story!'
    else
      story = choose do |menu|
        menu.prompt = options[:start]? 'Choose story to start: ': 'Choose story for details: '
        candidates.each do |story|
          name = "%8d %-7s %-25s [%-6s] #{'[owner: %s]' if story.owned_by}" %
              [story.id, story.story_type.upcase, story.name, story.current_state, story.owned_by]
          menu.choice(name) { story }
        end
      end
      puts
    end

    story
  end

end
