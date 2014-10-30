require 'rubygems'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = ['-c', '-f progress', '-r ./spec/spec_helper.rb']
  task.pattern    = 'spec/**/*_spec.rb'
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['*.rb', 'lib/*.rb', '-', '*.md']
end
