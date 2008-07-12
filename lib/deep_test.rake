begin
  require 'rubygems'
  require "deep_test/rake_tasks"
rescue LoadError
  puts "gem not installed : Install deep_test gem"
end

DeepTest::TestTask.new "deep_test:functional" do |t|
  t.pattern = "test/suites/functional/**/*_test.rb"
  t.number_of_workers = 2   # optional, defaults to 2
  t.timeout_in_seconds = 30 # optional, defaults to 30
  t.server_port = 6969      # optional, defaults to 6969
end
