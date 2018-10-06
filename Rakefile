# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['tests/**/test_*.rb']
end
desc 'Run tests'

task default: :test
