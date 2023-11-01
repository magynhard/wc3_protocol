require "bundler/gem_tasks"
require "rspec/core/rake_task"

require_relative 'lib/wc3_protocol'

#
# run default task to see tasks to build and publish gem
#
task :default do
  system 'rake --tasks'
end

task :test do
  system 'rspec'
end

task :playground do
  g = Wc3Protocol::Broadcast.find_games
  puts g.inspect
end

RSpec::Core::RakeTask.new(:spec)