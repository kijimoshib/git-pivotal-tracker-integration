#!/usr/bin/env ruby

message_file = ARGV[0]
message = File.read(message_file).strip

branchname = `git branch --no-color 2> /dev/null`[/^\* (.+)/, 1].to_s
story_id = `git config branch.#{branchname}.pivotal-story-id`.strip
reference = "[##{story_id}]"

message = [reference, message].join(" ")

File.open(message_file, 'w') {|f| f.write message }
